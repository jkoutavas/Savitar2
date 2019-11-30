//
//  Endpoint.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/13/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

public class Endpoint: NSObject, StreamDelegate {
    let port: UInt32
    let host: String
    let outputter: OutputProtocol

    var inputStream: InputStream!
    var outputStream: OutputStream!

    var telnetParser: TelnetParser?

    init(port: UInt32, host: String, outputter: OutputProtocol) {

        self.port = port
        self.host = host
        self.outputter = outputter
        self.telnetParser = TelnetParser()

        super.init()
    }

    func close() {
        inputStream.close()
        outputStream.close()
    }

    func connectAndRun() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        telnetParser!.mEndpoint = self

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                 host as CFString,
                                 port,
                                 &readStream,
                                 &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        if inputStream != nil && outputStream != nil {
            inputStream.delegate = self

            inputStream.schedule(in: .main, forMode: .common)
            outputStream.schedule(in: .main, forMode: .common)

            inputStream.open()
            outputStream.open()
        } else {
            outputter.output(result: .error("[SAVITAR] Failed Getting Streams"))
        }
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

    private func processAcceptedText(buffer: [UInt8]) -> Data {
        var data = Data()
        for char in buffer {
            if !telnetParser!.isTelnetByte(char: char) {
                data.append(char)
            }
        }
        return data
    }

    private func acceptText(stream: InputStream) {
        // Some data came in from the network. Queue its processing on a block thread.
        let blockOperation = { [weak self] in
            var data = Data()
            let maxReadLength = 4096
            while stream.hasBytesAvailable {
                var buffer = [UInt8](repeating: 0, count: maxReadLength)
                let read = stream.read(&buffer, maxLength: maxReadLength)
                if read > 0 {
                    if let result = self?.processAcceptedText(buffer: buffer) {
                        if result.count > 0 {
                            data.append(result)
                        }
                    }
                }
            }

            // Processing is complete. Queue output on the main thread
            OperationQueue.main.addOperation {
                let message = String(decoding: data, as: UTF8.self)
                self?.outputter.output(result: .success(message))
            }
        }
        OperationQueue().addOperation(blockOperation)
    }

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            guard let inputStream = aStream as? InputStream else { break }
            acceptText(stream: inputStream)
        case Stream.Event.endEncountered:
            print("new message received")
        case Stream.Event.errorOccurred:
            self.outputter.output(result: .error("[SAVITAR] stream error occurred"))
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
}
