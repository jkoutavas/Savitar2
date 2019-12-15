//
//  World.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa
import Logging
import SwiftyXMLParser

private func initLogger() -> Logger {
    var logger = Logger(label: String(describing: Bundle.main.bundleIdentifier))
    logger[metadataKey: "m"] = "World" // "m" is for "module"

    return logger
}

class World: NSController, NSCopying, SavitarXMLProtocol {
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

    var triggerMan = TriggerMan()

    // utility, not persistent
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

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    let TelnetIdentifier = "telnet://"
    let TriggersElemIdentifier = "TRIGGERS"
    let WorldElemIdentifier = "WORLD"

    // These are the <WORLD> XML element attributes
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

    func parse(xml: XML.Accessor) throws {
        logger.info("parsing \(String(describing: xml))")

        version = 1 // start with the assumption that v1 world XML is being parsed
        for attribute in xml.attributes {
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
                logger.info("skipping XML attribute \(attribute.key)")
            }
        }

        if case .singleElement = xml[TriggersElemIdentifier] {
            try triggerMan.parse(xml: xml)
        }
    }

    func toXMLElement() throws -> XMLElement {
        // TODO: provide a Savitar error model?

        if version != 2 {
            // yikes! this world should be modern if we're produce XML. Throw a fit
            throw NSError(domain: "wrong world version", code: 1, userInfo: nil)
        }

        let worldElem = XMLElement(name: WorldElemIdentifier)

        worldElem.addAttribute(name: WorldAttribIdentifier.version.rawValue, stringValue: "\(version)")

        worldElem.addAttribute(name: WorldAttribIdentifier.GUID.rawValue, stringValue: GUID)

        worldElem.addAttribute(name: WorldAttribIdentifier.URL.rawValue,
                        stringValue: "\(TelnetIdentifier)\(host):\(port)")

        worldElem.addAttribute(name: WorldAttribIdentifier.name.rawValue, stringValue: name)

        worldElem.addAttribute(name: WorldAttribIdentifier.font.rawValue, stringValue: fontName)

        worldElem.addAttribute(name: WorldAttribIdentifier.fontSize.rawValue, stringValue: "\(fontSize)")

        worldElem.addAttribute(name: WorldAttribIdentifier.monoFont.rawValue, stringValue: monoFontName)

        worldElem.addAttribute(name: WorldAttribIdentifier.monoFontSize.rawValue, stringValue: "\(monoFontSize)")

        if let colorStr = foreColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.foreColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = backColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.backColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = linkColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.linkColor.rawValue, stringValue: "#\(colorStr)")
        }

        logger.info("XML data representation \(String(worldElem.xmlString))")
        return worldElem
    }
}
