//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class Document: NSDocument, OutputProtocol {

    var endpoint: Endpoint?
    var splitViewController : SplitViewController?
  
    // TODO: just some hard-coded connection settings right now
    let port: UInt32 = 1337
    let host = "::1"
    
    override func close() {
        endpoint?.close()
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
        
        // TODO: ya-ya, this call should be elsewhere
        endpoint = Endpoint(port:port, host:host, outputter:self)
        self.splitViewController?.inputViewController.endpoint = endpoint
        
        endpoint?.connectAndRun()
        endpoint?.sendMessage(message: "Welcome to Savitar 2.0!")
        
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
    
    func output(result : OutputResult) {
        func output(string: String, attributes: [NSAttributedStringKey : Any]? = nil) {
            let outputView = self.splitViewController?.outputViewController.textView
        
            outputView?.textStorage?.append(NSAttributedString(string: string, attributes: attributes))
            outputView?.scrollToEndOfDocument(nil)
        }
        
        switch result {
            case .success(let message):
                output(string: message)
            case .error(let error):
                var attributes = [NSAttributedStringKey: AnyObject]()
                attributes[NSAttributedStringKey.foregroundColor] = NSColor.red
                output(string: error, attributes: attributes)
        }
    }
}
