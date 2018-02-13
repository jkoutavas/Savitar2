//
//  Endpoint.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/13/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation
import Socket

public class Endpoint {
    let port: Int32
    let host: String
    let outputter: OutputProtocol
    var socket: Socket?
    let bufferSize = 4096
    var connectionIsUp = false
    
    init(port: Int32, host: String, outputter: OutputProtocol) {
        self.port = port
        self.host = host
        self.outputter = outputter
    }
    
    func close() {
        socket?.close()
        connectionIsUp = false
    }
    
    func connectAndRun() {
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async { [unowned self] in
            do {
                // Create an IPV6 socket...
                self.socket = try Socket.create(family: .inet)
                try self.socket?.connect(to:self.host, port:self.port, timeout:0)
                self.connectionIsUp = true
                
                try self.socket?.write(from: "Welcome to Savitar 2.0!")
                
                repeat {
                    var readData = Data(capacity: self.bufferSize)
                    let bytesRead = try self.socket?.read(into: &readData)
                    if bytesRead! > 1 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            self.outputter.output(error:"Error decoding response...")
                            readData.count = 0
                            break
                        }
                        self.outputter.output(message: response)
                    }
                } while(self.connectionIsUp)
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    self.outputter.output(error:"Unexpected error...")
                    return
                }
                self.outputter.output(error:"Error reported:\n \(socketError.description)")
            }
        }
    }
}
