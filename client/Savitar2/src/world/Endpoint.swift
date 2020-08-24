//
//  Endpoint.swift
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
}

class Endpoint: NSObject, StreamDelegate {
    var status: ConnectionStatus = .New

    let world: World
    let outputter: OutputProtocol

    var inputStream: InputStream!
    var outputStream: OutputStream!

    var logger: Logger
    var telnetParser: TelnetParser?

    var universalMacros: [Macro] = []
    var universalTriggers: [Trigger] = []

    init(world: World, outputter: OutputProtocol) {
        self.world = world
        self.outputter = outputter
        self.logger = Logger(label: String(describing: Bundle.main.bundleIdentifier))
        self.logger[metadataKey: "a"] = "\(world.host):\(world.port)" // "a" is for "address"
        self.logger[metadataKey: "m"] = "Endpoint" // "m" is for "module"
        self.telnetParser = TelnetParser()

        AppContext.shared.worldMan.add(world)
    }

    func close() {
        status = .Disconnecting
        globalStore.unsubscribe(self)
        inputStream.close()
        outputStream.close()
        logger.info("closed connection")
        status = .DisconnectComplete
        outputter.sessionClosed()

        AppContext.shared.worldMan.remove(world)
    }

    func connectAndRun() {
        globalStore.subscribe(self)

        logger.info("connecting...")

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        telnetParser!.mEndpoint = self
        telnetParser!.logger = Logger(label: String(describing: Bundle.main.bundleIdentifier))
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
            outputter.output(result: .error("[SAVITAR] Failed Getting Streams"))
        }
    }

    func expandKeypress(with event: NSEvent) -> Bool {
        return processMacros(with: event, macros: universalMacros) ||
            processMacros(with: event, macros: world.macroMan.get())
    }

    func sendData(data: Data) {
        _ = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            outputStream.write(bufferPointer.baseAddress!, maxLength: data.count)
        }
    }

    func sendString(string: String) {
        sendData(data: string.data(using: .utf8)!)
    }

    func submitServerCmd(cmd: Command) {
        sendString(string: cmd.cmdStr)
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
                self?.outputter.output(result: .success(line))
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
        // Some data came in from the network. Queue its processing on a block thread.
        let blockOperation = { [weak self] in
            var data = Data()
            let maxReadLength = 4096
            while stream.hasBytesAvailable {
                var buffer = [UInt8](repeating: 0, count: maxReadLength)
                let read = stream.read(&buffer, maxLength: maxReadLength)
                if read > 0 {
                    if let result = self?.process(buffer: buffer) {
                        if result.count > 0 {
                            data.append(result)
                        }
                    }
                }
            }
            self?.processAcceptedText(text: String(decoding: data, as: UTF8.self))
        }
        OperationQueue().addOperation(blockOperation)
    }

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            status = .ConnectComplete
            outputter.sessionOpened()
            logger.info("open completed")
        case Stream.Event.hasBytesAvailable:
            guard let inputStream = aStream as? InputStream else { break }
            read(stream: inputStream)
        case Stream.Event.endEncountered:
            logger.info("new message received")
        case Stream.Event.errorOccurred:
            self.outputter.output(result: .error("[SAVITAR] stream error occurred"))
        case Stream.Event.hasSpaceAvailable:
            logger.info("has space available")
        default:
            logger.info("some other event...")
        }
    }
}

extension Endpoint: StoreSubscriber {
    func newState(state: ReactionsState) {
        self.universalMacros = state.macroList.items
        self.universalTriggers = state.triggerList.items
    }
}
