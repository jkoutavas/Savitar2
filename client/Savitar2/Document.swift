//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa
import Socket

class Document: NSDocument {

    // TODO: just some hard-coded connection settings right now
    let port: Int32 = 1337
    let host = "::1"
    
    // TODO: eventually move the connection related code to its own module
    var socket: Socket?
    let bufferSize = 4096
    var splitViewController : SplitViewController?
    var connectionIsUp = false
    
    override func close() {
        socket?.close()
        connectionIsUp = false
    }

    override class var autosavesInPlace: Bool {
        return false // TODO: eventually will want to enable this
    }
    
    override var isDocumentEdited: Bool {
        return false // TODO: eventually enable this
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        splitViewController = windowController.contentViewController as? SplitViewController
        windowController.window?.makeFirstResponder(splitViewController?.inputViewController.textView)
        
        connectAndRun() // TODO: ya-ya, this call should be elsewhere
        
        // TODO: add some kind os a listening mechanism to the splitViewController?.inputViewController
        // so as to pass along an inputted line of text once it has been entered
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    private func safeOutput(string: String, attributes: [NSAttributedStringKey : Any]? = nil) {
        // can be safely called via the connection run loop
        DispatchQueue.main.async { [unowned self] in
            let outputView = self.splitViewController?.outputViewController.textView
        
            outputView?.textStorage?.append(NSAttributedString(string: string, attributes: attributes))
        }
    }
    
    func output(message: String) {
        safeOutput(string: message)
    }
    
    func output(error: String) {
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = NSColor.red
        
        safeOutput(string: error, attributes: attributes)
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
                            self.output(error:"Error decoding response...")
                            readData.count = 0
                            break
                        }
                        self.output(message: response)
                    }
                } while(self.connectionIsUp)
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    self.output(error:"Unexpected error...")
                    return
                }
                self.output(error:"Error reported:\n \(socketError.description)")
            }
        }
    }
}

