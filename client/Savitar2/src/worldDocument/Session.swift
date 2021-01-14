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

    init(world: World, sessionHandler: SessionHandlerProtocol) {
        self.world = world
        self.sessionHandler = sessionHandler
        logger = Logger(label: "savitar2")
        logger[metadataKey: "a"] = "\(world.host):\(world.port)" // "a" is for "address"
        logger[metadataKey: "m"] = "Session" // "m" is for "module"

        queue.maxConcurrentOperationCount = 1
    }

    func close() {
        status = .Disconnecting
        AppContext.shared.universalReactionsStore.unsubscribe(self)
        inputStream.close()
        outputStream.close()
        logger.info("closed connection")
        status = .DisconnectComplete

        AppContext.shared.worldMan.remove(world)
        telnetParser = nil
    }

    func connectAndRun() {
        AppContext.shared.universalReactionsStore.subscribe(self)
        AppContext.shared.worldMan.add(world)

        didStartupCmd = false

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
            sessionHandler.output(result: .error("[SAVITAR] Failed Getting Streams"))
        }
    }

    func expandKeypress(with event: NSEvent) -> Bool {
        return processMacros(with: event, macros: universalMacros) ||
            processMacros(with: event, macros: world.macroMan.get())
    }

    func reallyCloseWindow() {
        status = .ReallyCloseWindow
    }

    func sendData(data: Data) {
        let blockOperation = { [weak self] in
            _ = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
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

    func submitServerCmd(cmd: Command) {
        // TODO: build out actual local command handler
        if cmd.cmdStr == "##dump" {
            sessionHandler.printSource()
            return
        }

        let str = "\(cmd.cmdStr)\n"
        if world.flags.contains(.echoCmds) {
            acceptedText(text: str)
        } else if world.flags.contains(.echoCR) {
            acceptedText(text: "\n")
        }
        sendString(string: str)
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
        // logger.info( "acceptedText: \"\(text)\" (\(text.endsWithNewline()))")

        let lines = text.split(omittingEmptySubsequences: false) {
            $0 == "\r" || $0 == "\n"
        }

        for (index, thisLine) in lines.enumerated() {
            var line = String(thisLine)

            // re-insert line ending for every line except the last
            if index < lines.count - 1 {
                line += "\r"
            }
            let effects = determineEffects(line: &line, excludedType: excludedTriggerType)

            // Processing is complete. Send the resulting line off to the output view
            acceptedText(text: line)

            // if there are some effects, handle them now
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
            line = processTriggers(inputLine: line, triggers: world.triggerMan.get(),
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
                submitServerCmd(cmd: Command(text: reply))
            }
            if effect.audioType != .silent {
                AppContext.shared.speakerMan.playAudio(trigger: effect,
                                                       muteSound: muteSound,
                                                       muteSpeaking: muteSpeaking)
            }
        }
    }

    private func acceptedText(text: String) {
        OperationQueue.main.addOperation { [weak self] in
            self?.sessionHandler.output(result: .success(text))
        }
    }

    private func processMacros(with event: NSEvent, macros: [Macro]) -> Bool {
        for macro in macros {
            if macro.isHotKey(forEvent: event) {
                sendString(string: macro.value)
                return true
            }
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
            if trigger.reactionTo(line: &line) {
                effects.append(trigger)
            }
        }
        if line.count > 0 {
            // Some text remains? (not all gagged away?) Check for subsitution reactions
            for trigger in filteredTriggers where !effects.contains(trigger) && trigger.useSubstitution {
                if trigger.reactionTo(line: &line) {
                    effects.append(trigger)
                }
            }
        }
        if line.count > 0 {
            // Check for remaining trigger reactions
            for trigger in filteredTriggers where !effects.contains(trigger) {
                if trigger.reactionTo(line: &line) {
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
                    let debugStr = String(decoding: buffer[0 ... read - 1], as: UTF8.self)
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
                self?.processAcceptedText(text: String(decoding: data, as: UTF8.self), excludedTriggerType: .input)
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
            }
            guard let inputStream = aStream as? InputStream else { break }
            read(stream: inputStream)
        case Stream.Event.endEncountered:
            logger.info("end encountered")
            close()
        case Stream.Event.errorOccurred:
            sessionHandler.output(result: .error("[SAVITAR] stream error occurred"))
            close()
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
