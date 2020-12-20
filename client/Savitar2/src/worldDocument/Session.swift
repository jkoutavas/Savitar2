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
        self.logger = Logger(label: "savitar2")
        self.logger[metadataKey: "a"] = "\(world.host):\(world.port)" // "a" is for "address"
        self.logger[metadataKey: "m"] = "Session" // "m" is for "module"

        self.queue.maxConcurrentOperationCount = 1
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

        self.telnetParser = TelnetParser()
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
        if inputStream != nil && outputStream != nil {
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
            self.sessionHandler.printSource()
            return
        }

        let str = "\(cmd.cmdStr)\r"
        if world.flags.contains(.echoCmds) {
           acceptedText(text: str)
        } else if world.flags.contains(.echoCR) {
           acceptedText(text: "\r")
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

    private func processAcceptedText(text: String) {
 //logger.info( "acceptedText: \"\(text)\" (\(text.endsWithNewline()))")

        let lines = text.split(omittingEmptySubsequences: false) {
            $0 == "\r" || $0 == "\n"
        }

        for (index, thisLine) in lines.enumerated() {
            var line = String(thisLine)

            // re-insert line ending for every line except the last
            if index < lines.count - 1 {
                 line += "\r"
             }
            var replies: [Command] = []
            line = processTriggers(inputLine: line, triggers: universalTriggers, replies: &replies)
            if line.count > 0 {
                line = processTriggers(inputLine: line, triggers: world.triggerMan.get(), replies: &replies)
            }

            // Processing is complete. Send the line off to the output view
            acceptedText(text: line)
            for reply in replies {
                submitServerCmd(cmd: reply)
            }
        }
    }

    private func acceptedText(text: String) {
        OperationQueue.main.addOperation({ [weak self] in
            self?.sessionHandler.output(result: .success(text))
        })
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

    private func processTriggers(inputLine: String, triggers: [Trigger], replies: inout [Command]) -> String {
        var line = inputLine

        // Handle trigger reactions. Often it'll result in a modification of the line, so let's
        // process triggers in this order:
        //    1. gagging triggers
        //    2. subsitution triggers
        //    3. all the rest
        var processedTriggers: [Trigger] = []
        for trigger in triggers {
            if !trigger.enabled {
                continue
            }
            if trigger.appearance == .gag {
                if trigger.reactionTo(line: &line) {
                    processedTriggers.append(trigger)
                }
            }
        }
        if line.count > 0 {
            for trigger in triggers {
                if !trigger.enabled {
                    continue
                }
                if trigger.useSubstitution && !processedTriggers.contains(trigger) {
                    if trigger.reactionTo(line: &line) {
                        processedTriggers.append(trigger)
                    }
                }
            }
        }
        if line.count > 0 {
            for trigger in triggers {
                if !trigger.enabled {
                    continue
                }
                if !processedTriggers.contains(trigger) {
                    if trigger.reactionTo(line: &line) {
                        processedTriggers.append(trigger)
                    }
                }
            }
        }

        // now handle any replies
        for trigger in processedTriggers {
            if let reply = trigger.reply, reply.count > 0 {
                replies.append(Command(text: reply))
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
                    let debugStr = String(decoding: buffer[0...read-1], as: UTF8.self)
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
                self?.processAcceptedText(text: String(decoding: data, as: UTF8.self))
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
            self.sessionHandler.output(result: .error("[SAVITAR] stream error occurred"))
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
        self.universalMacros = state.macroList.items
        self.universalTriggers = state.triggerList.items
    }
}
