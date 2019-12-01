//
//  World.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa
import Logging

private func initLogger() -> Logger {
    var logger = Logger(label: String(describing: Bundle.main.bundleIdentifier))
    logger[metadataKey: "m"] = "World" // "m" is for "module"

    return logger
}

class World: NSController, NSCopying, XMLParserDelegate {
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
        case monoFont = "MONO"
        case monoFontSize = "MONOSIZE"
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
    @objc dynamic var backColor = NSColor.white
    @objc dynamic var foreColor = NSColor.black
    @objc dynamic var linkColor = NSColor.blue
    @objc dynamic var fontName = "Monaco"
    @objc dynamic var fontSize: CGFloat = 9
    @objc dynamic var name: String = ""
    @objc dynamic var monoFontName = "Monaco"
    @objc dynamic var monoFontSize: CGFloat = 9
    var inputRows = 2
    var outputRows = 24
    var columns = 80
    var position = NSPoint(x: 44, y: 0)
    var windowSize = NSSize(width: 480, height: 270)
    var zoomed = false

    var version = 0
    var GUID = NSUUID().uuidString

    var logger: Logger

    init(world: World) {
        self.logger = initLogger()

        self.port = world.port
        self.host = world.host
        self.name = world.name
        self.backColor = world.backColor
        self.foreColor = world.foreColor
        self.linkColor = world.linkColor
        self.fontName = world.fontName
        self.fontSize = world.fontSize
        self.monoFontName = world.monoFontName
        self.monoFontSize = world.monoFontSize
        self.inputRows = world.inputRows
        self.columns = world.columns
        self.position = world.position
        self.windowSize = world.windowSize
        self.zoomed = world.zoomed
        self.version = world.version
        self.GUID = world.GUID

        super.init()
    }

    override init() {
         self.logger = initLogger()

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return World(world: self)
    }

    func read(from data: Data) throws {
        logger.info("reading \(String(decoding: data, as: UTF8.self))")

        /*
         * Parse XML for a v1 or v2 Savitar world document
         */
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        if elementName == WorldElemIdentifier {
            version = 1 // start with the assumption that a v1 document is being read
            for attribute in attributeDict {
                switch attribute.key {
                case WorldAttribIdentifier.URL.rawValue:
                    if attribute.value.hasPrefix(TelnetIdentifier) {
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
                case WorldAttribIdentifier.linkColor.rawValue:
                    linkColor = NSColor(hex: attribute.value)!
                case WorldAttribIdentifier.font.rawValue:
                    fontName = attribute.value
                case WorldAttribIdentifier.fontSize.rawValue:
                    guard let size = CGFloat(attribute.value) else { break }
                    fontSize = size
                case WorldAttribIdentifier.monoFont.rawValue:
                    monoFontName = attribute.value
                case WorldAttribIdentifier.monoFontSize.rawValue:
                    guard let size = CGFloat(attribute.value) else { break }
                    monoFontSize = size
                case WorldAttribIdentifier.name.rawValue:
                    name = attribute.value
                case WorldAttribIdentifier.position.rawValue:
                    let parts = attribute.value.components(separatedBy: ",")
                    if parts.count == 2 {
                        guard let x = CGFloat(parts[1]) else { break }
                        guard let y = CGFloat(parts[0]) else { break }
                        position = NSPoint(x: x, y: y)
                    }
                case WorldAttribIdentifier.windowSize.rawValue:
                    let parts = attribute.value.components(separatedBy: ",")
                    if parts.count == 2 {
                        guard let width = CGFloat(parts[0]) else { break }
                        guard let height = CGFloat(parts[1]) else { break }
                        windowSize = NSSize(width: width, height: height)
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
                    logger.info("skipping \(attribute.key)")
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

         // TODO: provide a Savitar error model?

        if version != 2 {
            // yikes! the document should be modern if we're doing a save. Throw a fit
            throw NSError(domain: "attempted to write obsolete world document", code: 1, userInfo: nil)
        }

        let root = XMLElement(name: DocumentElemIdentifier)
        guard let type = XMLNode.attribute(withName: "TYPE", stringValue: "Savitar World") as? XMLNode else {
            throw NSError()
        }
        root.addAttribute(type)

        guard let elem = XMLNode.element(withName: WorldElemIdentifier) as? XMLElement else {
            throw NSError()
        }
        let worldElem: XMLElement = elem

        guard let version = XMLNode.attribute(withName: WorldAttribIdentifier.version.rawValue,
                                              stringValue: "\(version)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(version)

        guard let guid = XMLNode.attribute(withName: WorldAttribIdentifier.GUID.rawValue,
                                           stringValue: "\(GUID)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(guid)

        let urlStr = "\(TelnetIdentifier)\(host):\(port)"
        guard let url = XMLNode.attribute(withName: WorldAttribIdentifier.URL.rawValue,
                                          stringValue: urlStr) as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(url)

        guard let name = XMLNode.attribute(withName: WorldAttribIdentifier.name.rawValue,
                                           stringValue: name) as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(name)

        guard let font = XMLNode.attribute(withName: WorldAttribIdentifier.font.rawValue,
                                           stringValue: fontName) as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(font)

        guard let fontSize = XMLNode.attribute(withName: WorldAttribIdentifier.fontSize.rawValue,
                                               stringValue: "\(fontSize)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(fontSize)

        guard let monoFont = XMLNode.attribute(withName: WorldAttribIdentifier.monoFont.rawValue,
                                           stringValue: monoFontName) as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(monoFont)

        guard let monoFontSize = XMLNode.attribute(withName: WorldAttribIdentifier.monoFontSize.rawValue,
                                               stringValue: "\(monoFontSize)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(monoFontSize)

        guard let foreColor = XMLNode.attribute(withName: WorldAttribIdentifier.foreColor.rawValue,
                                                stringValue: "#\(foreColor.toHex()!)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(foreColor)

        guard let backColor = XMLNode.attribute(withName: WorldAttribIdentifier.backColor.rawValue,
                                                stringValue: "#\(backColor.toHex()!)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(backColor)

        guard let linkColor = XMLNode.attribute(withName: WorldAttribIdentifier.linkColor.rawValue,
                                                stringValue: "#\(linkColor.toHex()!)") as? XMLNode else {
            throw NSError()
        }
        worldElem.addAttribute(linkColor)

        root.addChild(worldElem)

        let xml = XMLDocument(rootElement: root)
        logger.info("XML data representation \(String(xml.xmlString))")
        return xml.xmlString.data(using: String.Encoding.utf8)!
    }
}
