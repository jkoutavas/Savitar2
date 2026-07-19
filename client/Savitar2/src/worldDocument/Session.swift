//
//  Session.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/13/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa
import Logging
import ReSwift

enum ConnectionStatus {
    case New
    case BindStart
    case Binding
    case BindComplete
    case ConnectComplete
    case ConnectRetry
    case Disconnecting
    case DisconnectComplete
    case ReallyCloseWindow
}

class Session: NSObject, StreamDelegate {
    var status: ConnectionStatus = .New {
        didSet { sessionHandler.connectionStatusChanged(status: status) }
    }

    let captureReads = false // set to true for debugging
    var captureURL: URL?

    var world: World
    let sessionHandler: SessionHandlerProtocol

    var inputStream: InputStream!
    var outputStream: OutputStream!

    var logger: Logger
    var telnetParser: TelnetParser?

    var universalMacros: [Macro] = []
    var universalTriggers: [Trigger] = []

    let queue = OperationQueue()

    var didStartupCmd = false

    /// Initial wrap state for this session (from app Settings → Input & Display at connect time).
    let wordWrapEnabled: Bool

    /// Last time we wrote to the server (user cmds, macros, telnet replies, keepalives).
    private var lastOutboundActivity = Date()
    private var keepAliveTimer: Timer?

    /// Prevents double-register when auto-retry reconnects.
    private var sessionRegistered = false
    /// User hit Stop/Close — do not schedule auto-retry.
    private var suppressAutoRetry = false
    private var connectRetryTimer: Timer?

    init(world: World, sessionHandler: SessionHandlerProtocol) {
        self.world = world
        self.sessionHandler = sessionHandler
        wordWrapEnabled = AppContext.shared.prefs.flags.contains(.defaultWordWrap)
        logger = Logger(label: "savitar2")
        logger[metadataKey: "a"] = "\(world.host):\(world.port)" // "a" is for "address"
        logger[metadataKey: "m"] = "Session" // "m" is for "module"

        queue.maxConcurrentOperationCount = 1
    }

    func close(sendLogoff: Bool = false) {
        suppressAutoRetry = true
        cancelConnectRetryTimer()
        if sendLogoff {
            sendLogoffCommandsIfNeeded()
        }
        performClose()
    }

    /// Lines that would be sent when closing with logoff enabled (for tests).
    func logoffLinesToSend() -> [String] {
        let trimmed = world.logoffCmd.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return trimmed.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
    }

    private func sendLogoffCommandsIfNeeded() {
        guard status == .ConnectComplete else { return }
        for line in logoffLinesToSend() {
            submitServerCmd(cmd: Command(text: line))
        }
    }

    private func performClose() {
        cancelConnectRetryTimer()
        stopKeepAliveTimer()
        status = .Disconnecting
        if sessionRegistered {
            AppContext.shared.universalReactionsStore.unsubscribe(self)
            AppContext.shared.worldMan.remove(world)
            sessionRegistered = false
        }
        closeNetworkStreams()
        logger.info("closed connection")
        status = .DisconnectComplete
        telnetParser = nil
    }

    func connectAndRun() {
        suppressAutoRetry = false
        cancelConnectRetryTimer()
        registerSessionIfNeeded()
        didStartupCmd = false
        openConnection()
    }

    private func registerSessionIfNeeded() {
        guard !sessionRegistered else { return }
        AppContext.shared.universalReactionsStore.subscribe(self)
        AppContext.shared.worldMan.add(world)
        sessionRegistered = true
    }

    private func openConnection() {
        logger.info("connecting...")

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        telnetParser = TelnetParser()
        telnetParser!.mEndpoint = self
        telnetParser!.logger = Logger(label: "savitar2")
        telnetParser!.logger?[metadataKey: "m"] = "TelnetParser" // "m" is for "module"

        status = .BindStart
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           world.host as CFString,
                                           world.port,
                                           &readStream,
                                           &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        if captureReads {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                captureURL = dir.appendingPathComponent("\(world.name).capture")
                print("opening \(String(describing: captureURL))")
            }
        }

        status = .Binding
        if inputStream != nil, outputStream != nil {
            inputStream.delegate = self

            inputStream.schedule(in: .main, forMode: .common)
            outputStream.schedule(in: .main, forMode: .common)

            inputStream.open()
            outputStream.open()
            status = .BindComplete
        } else {
            handleConnectionFailure(message: "Failed getting streams.")
        }
    }

    private func closeNetworkStreams() {
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
    }

    func expandKeypress(with event: NSEvent) -> Bool {
        return processMacros(with: event, macros: universalMacros) ||
            processMacros(with: event, macros: liveWorldMacros())
    }

    private func liveWorldMacros() -> [Macro] {
        let live = sessionHandler.worldMacros()
        return live.isEmpty ? world.macroMan.get() : live
    }

    private func liveWorldTriggers() -> [Trigger] {
        let live = sessionHandler.worldTriggers()
        return live.isEmpty ? world.triggerMan.get() : live
    }

    func reallyCloseWindow() {
        suppressAutoRetry = true
        cancelConnectRetryTimer()
        status = .ReallyCloseWindow
    }

    func sendData(data: Data) {
        guard outputStream != nil else { return }
        noteOutboundActivity()
        let blockOperation = { [weak self] in
            data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
                //               self?.logger.info("sendData: \(data.hexString)")
                let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                self?.outputStream.write(bufferPointer.baseAddress!, maxLength: data.count)
            }
        }
        queue.addOperation(blockOperation)
    }

    func sendString(string: String) {
        sendData(data: string.data(using: .utf8)!)
    }

    // MARK: - Keepalive (v1 parity)

    private func noteOutboundActivity() {
        lastOutboundActivity = Date()
    }

    private func startKeepAliveTimer() {
        stopKeepAliveTimer()
        lastOutboundActivity = Date()
        let timer = Timer(timeInterval: SessionKeepAlive.pollIntervalSeconds, repeats: true) { [weak self] _ in
            self?.checkKeepAlive()
        }
        RunLoop.main.add(timer, forMode: .common)
        keepAliveTimer = timer
    }

    private func stopKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }

    private func checkKeepAlive() {
        guard status == .ConnectComplete else { return }
        guard SessionKeepAlive.shouldSend(
            keepAliveMins: world.keepAliveMins,
            lastOutbound: lastOutboundActivity
        ) else { return }
        sendKeepAlive()
    }

    /// Quiet null-byte probe after outbound idle — same as Savitar 1 `SendKeepAlive`.
    private func sendKeepAlive() {
        guard status == .ConnectComplete else { return }
        guard outputStream != nil else {
            handleConnectionFailure(message: "Keepalive failed (no stream).")
            return
        }

        noteOutboundActivity()
        let data = SessionKeepAlive.nullBytePayload
        queue.addOperation { [weak self] in
            guard let self else { return }
            guard let stream = self.outputStream else {
                self.runOnMain { self.handleConnectionFailure(message: "Keepalive failed (no stream).") }
                return
            }
            let written = data.withUnsafeBytes { rawBufferPointer -> Int in
                let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                guard let baseAddress = bufferPointer.baseAddress else { return -1 }
                return stream.write(baseAddress, maxLength: data.count)
            }
            if written < 0 {
                self.runOnMain { self.handleConnectionFailure(message: "Keepalive write failed.") }
            }
        }
    }

    // MARK: - Connect retry (v1 parity)

    private func cancelConnectRetryTimer() {
        connectRetryTimer?.invalidate()
        connectRetryTimer = nil
    }

    /// Unexpected disconnect / connect failure — auto-retry when Retry Seconds > 0.
    private func handleConnectionFailure(message: String) {
        guard status != .Disconnecting,
              status != .DisconnectComplete,
              status != .ReallyCloseWindow else { return }

        stopKeepAliveTimer()
        closeNetworkStreams()
        telnetParser = nil

        if !suppressAutoRetry, SessionConnectRetry.shouldAutoRetry(retrySecs: world.retrySecs) {
            let secs = world.retrySecs
            status = .ConnectRetry
            sessionHandler.output(result: .error("[SAVITAR] \(message) Retrying in \(secs)s…\n"))
            scheduleConnectRetry(after: SessionConnectRetry.delaySeconds(retrySecs: secs))
        } else {
            sessionHandler.output(result: .error("[SAVITAR] \(message)\n"))
            performClose()
        }
    }

    private func scheduleConnectRetry(after delay: TimeInterval) {
        cancelConnectRetryTimer()
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            self?.performScheduledConnectRetry()
        }
        RunLoop.main.add(timer, forMode: .common)
        connectRetryTimer = timer
    }

    private func performScheduledConnectRetry() {
        connectRetryTimer = nil
        guard !suppressAutoRetry, status == .ConnectRetry else { return }
        logger.info("auto-retry connecting...")
        didStartupCmd = false
        openConnection()
    }

    func submitServerCmd(cmd: Command) {
        let expandedCmd = expandVariables(in: cmd)
        if handleLocalCommand(expandedCmd) {
            return
        }

        let postfix = cmd.flags.contains(.dontPostFix) ? "" : world.commandLinePostfix
        let str = "\(expandedCmd.cmdStr)\(postfix)"
        if world.flags.contains(.echoCmds) {
            echoBack(text: str)
        } else if world.flags.contains(.echoCR) {
            echoBack(text: postfix == "\r" ? "\n" : "\r\n")
        }
        sendString(string: str)
    }

    private func expandVariables(in cmd: Command) -> Command {
        guard !cmd.flags.contains(.dontProcess) else { return cmd }

        let expandedText = world.variableMan.expand(cmd.cmdStr, marker: world.varMarker)
        guard expandedText != cmd.cmdStr else { return cmd }
        return Command(text: expandedText, flags: cmd.flags)
    }

    private func handleLocalCommand(_ cmd: Command) -> Bool {
        let trimmedCmd = cmd.cmdStr.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !world.cmdMarker.isEmpty else { return false }
        guard trimmedCmd.hasPrefix(world.cmdMarker) else { return false }

        let localCmd = String(trimmedCmd.dropFirst(world.cmdMarker.count))
        let parsed = SessionLocalCommands.parse(localCmd)
        SessionLocalCommandExecutor.execute(parsed, session: self)
        return true
    }

    private func process(buffer: [UInt8], length: Int) -> Data {
        var data = Data()
        var i = 0
        for char in buffer {
            if i == length {
                break
            }
            if !telnetParser!.isTelnetByte(char: char) {
                data.append(char)
            }
            i += 1
        }
        return data
    }

    private func processAcceptedText(text: String, excludedTriggerType: TrigType) {
        guard !text.isEmpty else { return }

        var index = text.startIndex
        while index < text.endIndex {
            let breakIndex = text[index...].firstIndex(where: { $0 == "\r" || $0 == "\n" })
            let lineEnd = breakIndex ?? text.endIndex
            var line = String(text[index ..< lineEnd])

            if let breakIndex = breakIndex {
                index = text.index(after: breakIndex)
                if text[breakIndex] == "\r", index < text.endIndex, text[index] == "\n" {
                    index = text.index(after: index)
                }
                line += "\n"
            } else {
                index = text.endIndex
            }

            let effects = determineEffects(line: &line, excludedType: excludedTriggerType)
            acceptedText(text: line)
            if effects.count > 0 {
                handleEffects(effects)
            }
        }
    }

    func determineEffects(line: inout String, excludedType: TrigType) -> [Trigger] {
        var effects: [Trigger] = []
        line = processTriggers(inputLine: line, triggers: universalTriggers, excludedType: excludedType,
                               effects: &effects)
        if line.count > 0 {
            line = processTriggers(inputLine: line, triggers: liveWorldTriggers(),
                                   excludedType: excludedType, effects: &effects)
        }
        return effects
    }

    func handleEffects(_ effects: [Trigger]) {
        // handle any audio or and/or reply effect
        let muteSound = AppContext.shared.prefs.flags.contains(.muteSound)
        let muteSpeaking = AppContext.shared.prefs.flags.contains(.muteSpeaking)

        for effect in effects {
            if let reply = effect.reply, reply.count > 0 {
                if effect.echoReply {
                    echoBack(text: "[Triggered reply:\"\(reply)\"]\n")
                }
                submitServerCmd(cmd: Command(text: reply, flags: .suppressEcho))
            }
            if effect.audioType != .silent {
                AppContext.shared.speakerMan.playAudio(trigger: effect,
                                                       muteSound: muteSound,
                                                       muteSpeaking: muteSpeaking)
            }
        }
    }

    private func acceptedText(text: String) {
        runOnMain { [weak self] in
            self?.sessionHandler.output(result: .success(text))
        }
    }

    private func echoBack(text: String) {
        runOnMain { [weak self] in
            self?.sessionHandler.outputEchoBack(text)
        }
    }

    private func runOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            OperationQueue.main.addOperation(block)
        }
    }

    private func processMacros(with event: NSEvent, macros: [Macro]) -> Bool {
        for macro in macros where macro.isHotKey(forEvent: event) {
            sendString(string: macro.value)
            return true
        }
        return false
    }

    func processTriggers(inputLine: String, triggers: [Trigger], excludedType: TrigType,
                         effects: inout [Trigger]) -> String {
        var line = inputLine

        // Determine the effects of enabled triggers of expected type
        // Often it'll result in a modification of the line, so let's process these triggers in this order:
        //    1. gagging triggers
        //    2. subsitution triggers

        var filteredTriggers = triggers
        filteredTriggers.removeAll(where: { !$0.enabled || $0.type == excludedType })

        // Check for gag reactions
        for trigger in filteredTriggers where trigger.appearance == .gag {
            let reaction = trigger.reactionTo(line: &line, wildMarker: world.wildMarker)
            if reaction.matched {
                world.variableMan.set(reaction.captures)
                effects.append(trigger)
            }
        }
        if line.count > 0 {
            // Some text remains? (not all gagged away?) Check for subsitution reactions
            for trigger in filteredTriggers where !effects.contains(trigger) && trigger.useSubstitution {
                let reaction = trigger.reactionTo(line: &line, wildMarker: world.wildMarker)
                if reaction.matched {
                    world.variableMan.set(reaction.captures)
                    effects.append(trigger)
                }
            }
        }
        if line.count > 0 {
            // Check for remaining trigger reactions
            for trigger in filteredTriggers where !effects.contains(trigger) {
                let reaction = trigger.reactionTo(line: &line, wildMarker: world.wildMarker)
                if reaction.matched {
                    world.variableMan.set(reaction.captures)
                    effects.append(trigger)
                }
            }
        }

        return line
    }

    private func read(stream: InputStream) {
        // Some data came in from the network. Queue its processing on a bzlock thread.
        let blockOperation = { [weak self] in
            var data = Data()
            let maxReadLength = 4096
            var buffer = [UInt8](repeating: 0, count: maxReadLength)
            while stream.hasBytesAvailable {
                let read = stream.read(&buffer, maxLength: maxReadLength)
                if read > 0 {
                    let debugStr = String(bytes: buffer[0 ..< read], encoding: .utf8) ?? ""
//                    self?.logger.info(
//                      "\(read) bytes read (\(debugStr.endsWithNewline() ? "true" : "false")) \(debugStr)")
                    if let url = self?.captureURL {
                        do {
                            try debugStr.write(to: url, atomically: false, encoding: .utf8)
                        } catch {}
                    }
                    if let result = self?.process(buffer: buffer, length: read) {
                        if result.count > 0 {
                            data.append(result)
                        }
                    }
                }
            }
            if data.count > 0 {
                self?.processAcceptedText(text: String(bytes: data, encoding: .utf8) ?? "",
                                          excludedTriggerType: .input)
                if let didStartupCmd = self?.didStartupCmd, !didStartupCmd {
                    self?.didStartupCmd = true
                    if let logonCmd = self?.world.logonCmd, logonCmd.count > 0 {
                        self?.submitServerCmd(cmd: Command(text: logonCmd))
                    }
                }
            }
        }
        queue.addOperation(blockOperation)
    }

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            logger.info("open completed")
        case Stream.Event.hasBytesAvailable:
            if status != .ConnectComplete {
                status = .ConnectComplete
                startKeepAliveTimer()
            }
            guard let inputStream = aStream as? InputStream else { break }
            read(stream: inputStream)
        case Stream.Event.endEncountered:
            logger.info("end encountered")
            handleConnectionFailure(message: "Connection closed by remote host.")
        case Stream.Event.errorOccurred:
            handleConnectionFailure(message: "Stream error occurred.")
        case Stream.Event.hasSpaceAvailable:
            logger.info("has space available")
        default:
            logger.info("some other event...")
        }
    }
}

extension Session: StoreSubscriber {
    func newState(state: ReactionsState) {
        universalMacros = state.macroList.items
        universalTriggers = state.triggerList.items
    }
}
