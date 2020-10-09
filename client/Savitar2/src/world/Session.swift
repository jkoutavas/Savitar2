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

    let world: World
    let sessionHandler: SessionHandlerProtocol

    var inputStream: InputStream!
    var outputStream: OutputStream!

    var logger: Logger
    var telnetParser: TelnetParser?

    var universalMacros: [Macro] = []
    var universalTriggers: [Trigger] = []

    init(world: World, sessionHandler: SessionHandlerProtocol) {
        self.world = world
        self.sessionHandler = sessionHandler
        self.logger = Logger(label: "savitar2")
        self.logger[metadataKey: "a"] = "\(world.host):\(world.port)" // "a" is for "address"
        self.logger[metadataKey: "m"] = "Session" // "m" is for "module"
    }

    func close() {
        status = .Disconnecting
        globalStore.unsubscribe(self)
        inputStream.close()
        outputStream.close()
        logger.info("closed connection")
        status = .DisconnectComplete

        AppContext.shared.worldMan.remove(world)
        telnetParser = nil
    }

    func connectAndRun() {
        globalStore.subscribe(self)
        AppContext.shared.worldMan.add(world)

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
                self?.logger.info("sendData: \(data.hexString)")
                let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                self?.outputStream.write(bufferPointer.baseAddress!, maxLength: data.count)
            }
        }
        OperationQueue().addOperation(blockOperation)
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

        sendString(string: "\(cmd.cmdStr)\r")
    }

    private func process(buffer: [UInt8]) -> Data {
        var data = Data()
        for char in buffer {
            if char == 0 {
                break
            }
            if !telnetParser!.isTelnetByte(char: char) {
                data.append(char)
            }
        }
        return data
    }

    private func processAcceptedText(text: String) {
        let lines = text.split(omittingEmptySubsequences: false) {
            $0 == "\r\n" || $0 == "\n"
        }

        for thisLine in lines {
            var line = String(thisLine)
            if line.count == 0 {
                // This was an empty subsequence, cause a line feed
                line = "<br>"
                continue
            }

            line = processTriggers(inputLine: line, triggers: universalTriggers)
            if line.count > 0 {
                line = processTriggers(inputLine: line, triggers: world.triggerMan.get())
            }

            // Processing is complete. Send the line off to the output view
            OperationQueue.main.addOperation({ [weak self] in
                self?.sessionHandler.output(result: .success(line))
            })
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

    private func processTriggers(inputLine: String, triggers: [Trigger]) -> String {
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
                line = trigger.reactionTo(line: line)
                processedTriggers.append(trigger)
            }
        }
        if line.count > 0 {
            for trigger in triggers {
                if !trigger.enabled {
                    continue
                }
                if trigger.useSubstitution && !processedTriggers.contains(trigger) {
                    line = trigger.reactionTo(line: line)
                    processedTriggers.append(trigger)
                }
            }
        }
        if line.count > 0 {
            for trigger in triggers {
                if !trigger.enabled {
                    continue
                }
                if !processedTriggers.contains(trigger) {
                    line = trigger.reactionTo(line: line)
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
                    let debugStr = String(decoding: buffer[0...read-1], as: UTF8.self)
                    self?.logger.info("\(read) bytes read (\(debugStr.endsWithNewline() ? "true" : "false")) \(debugStr)")
                    if let result = self?.process(buffer: buffer, length: read) {
                        if result.count > 0 {
                            data.append(result)
                        }
                    }
                }
            }
            if data.count > 0 {
                self?.processAcceptedText(text: String(decoding: data, as: UTF8.self))
            }
        }
        OperationQueue().addOperation(blockOperation)
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
