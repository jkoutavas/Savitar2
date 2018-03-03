//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa

// TODO: move these to extensions modules
extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}
extension CGFloat {
    init?(_ str: String) {
        guard let float = Float(str) else { return nil }
        self = CGFloat(float)
    }
}

class Document: NSDocument, XMLParserDelegate, OutputProtocol {

    // these define the "WORLD" attributes found in Savitar 1.x world documents
    enum WorldAttribIdentifier: String {
        // these are obsoleted in v2
        case resolution = "RESOLUTION"
        case position = "POSITION"
        case windowSize = "WINDOWSIZE"
        case zoomed = "ZOOMED"
        
        // these are shared between v1 and v2
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
        
        // these are new for v2
        case version = "VERSION"
        case GUID = "GUID"
    }
    
    let TelnetIdentifier = "telnet://"
    let DocumentElemIdentifier = "DOCUMENT"
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
    
    var version = 1
    var GUID = NSUUID().uuidString
    
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

    override var isInViewingMode: Bool {
        return shouldBeMigrated()
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
        windowController.windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: GUID)
        splitViewController?.splitView.autosaveName = NSSplitView.AutosaveName(rawValue: GUID)
        
        window.setIsZoomed(zoomed)

        output(result:.success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port:port, host:host, outputter:self)
        svc.inputViewController.endpoint = endpoint
        endpoint?.connectAndRun()
        
        if shouldBeMigrated() {
            // TODO: pop-up an alert to explain to user that "Save As..." should
            // be done to properly migrate to v2 document, thus gaining auto save
            // and save in place support
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        /*
         * Write-out XML for a v2 Savitar world document
         *
         * You may wonder, why XML in this modern age? Why not do a PLIST or codable thing? Or use JSON?
         * Answer: We stay away from Apple specific formats like PLIST and codable because we want the
         * world document to be easily readable from anywhere, any platform. True, in this modern age,
         * JSON would fit that requirement, but, there's something to be said about having some semblence
         * still with the v1 document's format, and it's not that hard to read and write XML. So: XML it is
         */
        
        if shouldBeMigrated() {
            // yikes! the document should be modern if we're doing a save. Throw a fit
            throw NSError(domain: "attempted to write obsolete world document", code: 1, userInfo: nil) // TODO: provide a Savitar error model?
        }
        
        let root = XMLElement(name: DocumentElemIdentifier)
        root.addAttribute(XMLNode.attribute(withName:"TYPE", stringValue:"Savitar World") as! XMLNode)
        let worldElem: XMLElement = XMLNode.element(withName: WorldElemIdentifier) as! XMLElement
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.version.rawValue, stringValue:"\(version)") as! XMLNode)
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.GUID.rawValue, stringValue:"\(GUID)") as! XMLNode)
       
        let url = "\(TelnetIdentifier)\(host):\(port)"
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.URL.rawValue, stringValue:url) as! XMLNode)
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.font.rawValue, stringValue:fontName) as! XMLNode)
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.fontSize.rawValue, stringValue:"\(fontSize)") as! XMLNode)
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.foreColor.rawValue, stringValue:"#\(foreColor.toHex()!)") as! XMLNode)
        
        worldElem.addAttribute(XMLNode.attribute(withName: WorldAttribIdentifier.backColor.rawValue, stringValue:"#\(backColor.toHex()!)") as! XMLNode)
        
        root.addChild(worldElem)
        
        
        let xml = XMLDocument(rootElement: root)
        Swift.print(xml.xmlString)
        return xml.xmlString.data(using: String.Encoding.utf8)!
    }

    override func read(from data: Data, ofType typeName: String) throws {
        /*
         * Parse XML for a v1 or v2 Savitar world document
         */
        let parser = XMLParser(data: data)
        parser.delegate = self;
        parser.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == WorldElemIdentifier {
            version = 1 // start with the assumption that a v1 document is being read
            for attribute in attributeDict {
                switch attribute.key {
                    case WorldAttribIdentifier.URL.rawValue:
                        if (attribute.value.hasPrefix(TelnetIdentifier)) {
                            let body = attribute.value.dropPrefix(TelnetIdentifier)
                            let parts = body.components(separatedBy: ":")
                            if parts.count == 2 {
                                host = parts[0]
                                guard let p1 = UInt32(parts[1]) else { break }
                                port = p1
                            }
                        }
                    case WorldAttribIdentifier.backColor.rawValue:
                        backColor = NSColor(hex: attribute.value)!
                    case WorldAttribIdentifier.foreColor.rawValue:
                        foreColor = NSColor(hex: attribute.value)!
                    case WorldAttribIdentifier.font.rawValue:
                        fontName = attribute.value
                    case WorldAttribIdentifier.fontSize.rawValue:
                        guard let size = CGFloat(attribute.value) else { break }
                        fontSize = size
                    case WorldAttribIdentifier.position.rawValue:
                        let parts = attribute.value.components(separatedBy: ",")
                        if parts.count == 2 {
                            guard let x = CGFloat(parts[1]) else { break }
                            guard let y = CGFloat(parts[0]) else { break }
                            position = NSMakePoint(x, y)
                        }
                    case WorldAttribIdentifier.windowSize.rawValue:
                        let parts = attribute.value.components(separatedBy: ",")
                        if parts.count == 2 {
                            guard let width = CGFloat(parts[0]) else { break }
                            guard let height = CGFloat(parts[1]) else { break }
                            windowSize = NSMakeSize(width, height)
                        }
                    case WorldAttribIdentifier.resolution.rawValue:
                        let parts = attribute.value.components(separatedBy: "x")
                        if parts.count == 3 {
                            guard let n0 = Int(parts[0]) else { break }
                            guard let n1 = Int(parts[1]) else { break }
                            guard let n2 = Int(parts[2]) else { break }
                            outputRows = n0
                            columns = n1
                            inputRows = n2
                        }
                    case WorldAttribIdentifier.zoomed.rawValue:
                        zoomed = attribute.value == "TRUE"
                    case WorldAttribIdentifier.version.rawValue:
                        guard let v = Int(attribute.value) else { break }
                        version = v // found a version attribute? Then we're v2 or later (version attribute got added in v2)
                    case WorldAttribIdentifier.GUID.rawValue:
                        GUID = attribute.value
                    default:
                        Swift.print("skipping \(attribute.key)")
                }
            }
        }
    }


    func shouldBeMigrated() -> Bool {
        return version == 1
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
