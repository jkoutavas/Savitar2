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
    let maxReadLength = 4096

    init(port: UInt32, host: String, outputter: OutputProtocol) {
        self.port = port
        self.host = host
        self.outputter = outputter
    }
    
    func close() {
        inputStream.close()
        outputStream.close()
    }
    
    func connectAndRun() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                 host as CFString,
                                 port,
                                 &readStream,
                                 &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        if inputStream != nil && outputStream != nil {
            inputStream.delegate = self
            
            inputStream.schedule(in: .current, forMode: .commonModes)
            outputStream.schedule(in: .current, forMode: .commonModes)

            inputStream.open()
            outputStream.open()
        } else {
            outputter.output(result:.error("[SAVITAR] Failed Getting Streams"))
        }
    }
    
    func sendMessage(message: String) {
        let data = message.data(using: .ascii)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        while stream.hasBytesAvailable {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            guard let message = String(bytesNoCopy: buffer,
                                     length: numberOfBytesRead,
                                     encoding: .ascii,
                                     freeWhenDone: true)
            else { return }
            outputter.output(result:.success(message))
        }
    }

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
          readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
          print("new message received")
        case Stream.Event.errorOccurred:
          self.outputter.output(result:.error("[SAVITAR] stream error occurred"))
        case Stream.Event.hasSpaceAvailable:
          print("has space available")
        default:
          print("some other event...")
          break
        }
    }
}