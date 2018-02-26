//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}

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
        case resolution = "RESOLUTION" // obsoleted for Sav 2.0 writing
        case position = "POSITION" // obsoleted for Sav 2.0 writing
        case windowSize = "WINDOWSIZE" // obsoleted for Sav 2.0 writing
        case zoomed = "ZOOMED" // obsoleted for Sav 2.0 writing
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
    
    // world settings with defaults
    var backColor = NSColor.white
    var foreColor = NSColor.black
    var fontName = "Monaco"
    var fontSize: CGFloat = 9
    var inputRows = 2
    var outputRows = 24
    var columns = 80
    var position = NSMakePoint(44, 0)
    var windowSize = NSMakeSize(480,270)
    var zoomed = false
    
    override func close() {
        super.close()
        endpoint?.close()
    }

    override class var autosavesInPlace: Bool {
        return true
    }
    
    override var isDocumentEdited: Bool {
        return false // TODO: eventually enable this
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController else { return }
        
        self.addWindowController(windowController)
        
        splitViewController = windowController.contentViewController as? SplitViewController
        guard let svc = splitViewController else { return }
        
        guard let window = windowController.window else { return }
        window.makeFirstResponder(svc.inputViewController.textView)

        svc.inputViewController.foreColor = foreColor
        svc.inputViewController.backColor = backColor
        svc.outputViewController.foreColor = foreColor
        svc.outputViewController.backColor = backColor
        
        if let font = NSFont(name: fontName, size: fontSize) {
            svc.inputViewController.font = font
            svc.outputViewController.font = font
        }
        
        window.setContentSize(windowSize)
        if let titleHeight = (windowController.window?.titlebarHeight) {
            if let screenSize = NSScreen.main?.frame.size {
                window.setFrameTopLeftPoint(NSMakePoint(position.x, screenSize.height - position.y + titleHeight))
            }
        }
        
        let dividerHeight: CGFloat = svc.splitView.dividerThickness
        let rowHeight = svc.inputViewController.rowHeight
        let split: CGFloat = windowSize.height - dividerHeight - rowHeight * CGFloat(inputRows+1)
        svc.splitView.setPosition(split, ofDividerAt: 0)
        
        window.setIsZoomed(zoomed)

        output(result:.success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port:port, host:host, outputter:self)
        svc.inputViewController.endpoint = endpoint
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
                    case WorldAttribIdentifier.backColor.rawValue:
                        backColor = NSColor(hex: attribute.value)!
                    case WorldAttribIdentifier.foreColor.rawValue:
                        foreColor = NSColor(hex: attribute.value)!
                    case WorldAttribIdentifier.font.rawValue:
                        fontName = attribute.value
                    case WorldAttribIdentifier.fontSize.rawValue:
                        fontSize = CGFloat(Int(attribute.value)!)
                    case WorldAttribIdentifier.position.rawValue:
                        let parts = attribute.value.components(separatedBy: ",")
                        position = NSMakePoint(CGFloat(Int(parts[1])!), CGFloat(Int(parts[0])!))
                    case WorldAttribIdentifier.windowSize.rawValue:
                        let parts = attribute.value.components(separatedBy: ",")
                        windowSize = NSMakeSize(CGFloat(Int(parts[0])!), CGFloat(Int(parts[1])!))
                    case WorldAttribIdentifier.resolution.rawValue:
                        let parts = attribute.value.components(separatedBy: "x")
                        outputRows = Int(parts[0])!
                        columns = Int(parts[1])!
                        inputRows = Int(parts[2])!
                    case WorldAttribIdentifier.zoomed.rawValue:
                        zoomed = attribute.value == "TRUE"
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
        
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.font] = NSFont(name: fontName, size: fontSize)
        switch result {
            case .success(let message):
                attributes[NSAttributedStringKey.foregroundColor] = foreColor
                output(string: message, attributes: attributes)
            case .error(let error):
                attributes[NSAttributedStringKey.foregroundColor] = NSColor.red
                output(string: error, attributes: attributes)
        }
    }
}
