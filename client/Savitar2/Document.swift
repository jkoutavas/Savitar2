//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa

class Document: NSDocument, XMLParserDelegate, OutputProtocol {

    // these define the "WORLD" attributes found in Savitar 1.x world documents
    enum WorldAttribIdentifier: String {
        case name = "NAME"
        case URL = "URL"
        case flags = "FLAGS"
        case cmdMarker = "CMDMARKER"
        case varMarker = "VARMARKER"
        case wildMarker = "WILDMARKER"
        case font = "FONT"
        case fontSize = "FONTSIZE"
        case mono = "MONO"
        case monoSize = "MONOSIZE"
        case MCPFont = "MCPFONT"
        case MCPFontSize = "MCPFONTSIZE"
        case resolution = "RESOLUTION"
        case position = "POSITION"
        case windowSize = "WINDOWSIZE"
        case zoomed = "ZOOMED"
        case foreColor = "FORECOLOR"
        case backColor = "BACKCOLOR"
        case linkColor = "LINKCOLOR"
        case echoBackColor = "ECHOBGCOLOR"
        case intenseColor = "INTENSECOLOR"
        case intenseType = "INTENSETYPE"
        case outputMax = "OUTPUTMAX"
        case outputMin = "OUTPUTMIN"
        case flushTicks = "FLUSHTICKS"
        case retrySecs = "RETRYSECS"
        case keepaliveMins = "KEEPALIVEMINS"
        case logonCmd = "LOGONCMD"
        case logoffCmd = "LOGOFFCMD"
    }
    
    let TelnetIdentifier = "telnet://"
    let WorldElemIdentifier = "WORLD"
    
    var endpoint: Endpoint?
    var splitViewController : SplitViewController?
  
    // TODO: just some hard-coded connection settings right now
    var port: UInt32 = 1337
    var host = "::1"
    
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

        self.output(result:.success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port:port, host:host, outputter:self)
        self.splitViewController?.inputViewController.endpoint = endpoint
        endpoint?.connectAndRun()
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
        let parser = XMLParser(data: data)
        parser.delegate = self;
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == WorldElemIdentifier {
            for attribute in attributeDict {
                switch attribute.key {
                    case WorldAttribIdentifier.URL.rawValue:
                        if (attribute.value.hasPrefix(TelnetIdentifier)) {
                            let body = attribute.value.dropPrefix(TelnetIdentifier)
                            let parts = body.components(separatedBy: ":")
                            host = parts[0]
                            port = UInt32(parts[1])!
                        }
                    default:
                        Swift.print("skipping \(attribute.key)")
                }
            }
        }
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
