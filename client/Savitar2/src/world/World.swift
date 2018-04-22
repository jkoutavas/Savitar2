//
//  World.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa

class World : NSController, XMLParserDelegate {
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

    @objc dynamic var editable: Bool {
        get {
            return version != 1
        }
    }
    
    // TODO: just some hard-coded connection settings right now
    @objc dynamic var port: UInt32 = 1337
    @objc dynamic var host = "::1"
    
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
    
    var version = 0
    var GUID = NSUUID().uuidString
    
    func read(from data: Data) throws {
        /*
         * Parse XML for a v1 or v2 Savitar world document
         */
        let parser = XMLParser(data: data)
        parser.delegate = self
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
    
    func data() throws -> Data {
        /*
         * Write-out XML for a v2 Savitar world document
         *
         * You may wonder, why XML in this modern age? Why not do a PLIST or codable thing? Or use JSON?
         * Answer: We stay away from Apple specific formats like PLIST and codable because we want the
         * world document to be easily readable from anywhere, any platform. True, in this modern age,
         * JSON would fit that requirement, but, there's something to be said about having some semblence
         * still with the v1 document's format, and it's not that hard to read and write XML. So: XML it is
         */
        
        if version != 2 {
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
}
