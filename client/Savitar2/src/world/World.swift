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

let WorldElemIdentifier = "WORLD"

private func initLogger() -> Logger {
    var logger = Logger(label: String(describing: Bundle.main.bundleIdentifier))
    logger[metadataKey: "m"] = "World" // "m" is for "module"

    return logger
}

struct WorldFlags: OptionSet, Hashable {
    let rawValue: Int

    static let ansi = WorldFlags(rawValue: 1 << 0)
    static let html = WorldFlags(rawValue: 1 << 1)
}
extension WorldFlags: StrOptionSet {
    // TODO: I wonder if there's a DRY-er way to do these
    static var labels: [Label] { return [
        (.ansi, "ansi"),
        (.html, "html")
    ]}
    static var labelDict: [String: Self] { return [
        "ansi": .ansi,
        "html": .html
    ]}
}

enum IntensityType: Int {
    case auto
    case bold
    case color
}

// TODO: make World an NSObject, SabvitarXMLProtocol, then subclass WorldController
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
    @objc dynamic var name: String = ""
    var flags: WorldFlags = [.ansi, .html]
    @objc dynamic var cmdMarker = "##"
    @objc dynamic var varMarker = "%%"
    @objc dynamic var wildMarker = "$$"
    @objc dynamic var backColor = NSColor.white
    @objc dynamic var foreColor = NSColor.black
    @objc dynamic var linkColor = NSColor.blue
    @objc dynamic var echoBackColor = NSColor.init(hex: "9CA6FF")!
    @objc dynamic var intenseColor = NSColor.white
    @objc dynamic var fontName = "Monaco"
    @objc dynamic var fontSize: CGFloat = 9
    @objc dynamic var monoFontName = "Monaco"
    @objc dynamic var monoFontSize: CGFloat = 9
    @objc dynamic var MCPFontName = "Monaco"
    @objc dynamic var MCPFontSize: CGFloat = 9
    var intensityType: IntensityType = .auto
    var inputRows = 2
    var outputRows = 24
    var columns = 80
    var position = NSPoint(x: 44, y: 0)
    var windowSize = NSSize(width: 480, height: 270)
    var zoomed = false
    var outputMax = 100 * 1024
    var outputMin = 25 * 1024
    var flushTicks = 30
    var retrySecs = 0
    var keepAliveMins = 0

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
        self.flags = world.flags
        self.cmdMarker = world.cmdMarker
        self.varMarker = world.varMarker
        self.wildMarker = world.wildMarker
        self.backColor = world.backColor
        self.foreColor = world.foreColor
        self.linkColor = world.linkColor
        self.echoBackColor = world.echoBackColor
        self.intenseColor = world.intenseColor
        self.intensityType = world.intensityType
        self.fontName = world.fontName
        self.fontSize = world.fontSize
        self.monoFontName = world.monoFontName
        self.monoFontSize = world.monoFontSize
        self.MCPFontName = world.MCPFontName
        self.MCPFontSize = world.MCPFontSize
        self.inputRows = world.inputRows
        self.columns = world.columns
        self.position = world.position
        self.windowSize = world.windowSize
        self.zoomed = world.zoomed
        self.outputMax = world.outputMax
        self.outputMin = world.outputMin
        self.flushTicks = world.flushTicks
        self.retrySecs = world.retrySecs
        self.keepAliveMins = world.keepAliveMins
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
        case keepAliveMins = "KEEPALIVEMINS"
        case logonCmd = "LOGONCMD"
        case logoffCmd = "LOGOFFCMD"

        // these are new for v2
        case version = "VERSION"
        case GUID = "GUID"
    }

    func parse(xml: XML.Accessor) throws {
        logger.info("parsing \(String(describing: xml))")

        let intensityLabels: [String: IntensityType] = [
            "auto": .auto,
            "bold": .bold,
            "color": .color
        ]

        version = 1 // start with the assumption that v1 world XML is being parsed
        for attribute in xml.attributes {
            switch attribute.key {
            case WorldAttribIdentifier.name.rawValue:
                name = attribute.value

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

            case WorldAttribIdentifier.flags.rawValue:
                flags = WorldFlags.from(string: attribute.value)

            case WorldAttribIdentifier.cmdMarker.rawValue:
                cmdMarker = attribute.value

            case WorldAttribIdentifier.varMarker.rawValue:
                varMarker = attribute.value

            case WorldAttribIdentifier.wildMarker.rawValue:
                wildMarker = attribute.value

            case WorldAttribIdentifier.backColor.rawValue:
                backColor = NSColor(hex: attribute.value)!

            case WorldAttribIdentifier.foreColor.rawValue:
                foreColor = NSColor(hex: attribute.value)!

            case WorldAttribIdentifier.linkColor.rawValue:
                linkColor = NSColor(hex: attribute.value)!

            case WorldAttribIdentifier.echoBackColor.rawValue:
                echoBackColor = NSColor(hex: attribute.value)!

            case WorldAttribIdentifier.intenseColor.rawValue:
                intenseColor = NSColor(hex: attribute.value)!

            case WorldAttribIdentifier.intenseType.rawValue:
                intensityType = .auto
                if let type = intensityLabels[attribute.value] {
                    // v2 uses a string description
                    intensityType = type
                } else {
                    // v1 uses an index
                    if let i = Int(attribute.value) {
                        if let type = IntensityType(rawValue: i) {
                            intensityType = type
                        }
                    }
                }

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

            case WorldAttribIdentifier.MCPFont.rawValue:
                MCPFontName = attribute.value

            case WorldAttribIdentifier.MCPFontSize.rawValue:
                guard let size = CGFloat(attribute.value) else { break }
                MCPFontSize = size

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

            case WorldAttribIdentifier.zoomed.rawValue:
                zoomed = attribute.value == "TRUE"

            case WorldAttribIdentifier.outputMax.rawValue:
                if let value = Int(attribute.value) {
                    outputMax = value
                }

            case WorldAttribIdentifier.outputMin.rawValue:
                if let value = Int(attribute.value) {
                    outputMin = value
                }

            case WorldAttribIdentifier.flushTicks.rawValue:
                if let value = Int(attribute.value) {
                    flushTicks = value
                }

            case WorldAttribIdentifier.retrySecs.rawValue:
                if let value = Int(attribute.value) {
                    retrySecs = value
                }

            case WorldAttribIdentifier.keepAliveMins.rawValue:
                if let value = Int(attribute.value) {
                    keepAliveMins = value
                }

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
        version = 2

        let worldElem = XMLElement(name: WorldElemIdentifier)

        worldElem.addAttribute(name: WorldAttribIdentifier.version.rawValue, stringValue: "\(version)")

        worldElem.addAttribute(name: WorldAttribIdentifier.GUID.rawValue, stringValue: GUID)

        worldElem.addAttribute(name: WorldAttribIdentifier.URL.rawValue,
                        stringValue: "\(TelnetIdentifier)\(host):\(port)")

        worldElem.addAttribute(name: WorldAttribIdentifier.name.rawValue, stringValue: name)

        worldElem.addAttribute(name: WorldAttribIdentifier.flags.rawValue, stringValue: flags.description)

        worldElem.addAttribute(name: WorldAttribIdentifier.cmdMarker.rawValue, stringValue: cmdMarker)

        worldElem.addAttribute(name: WorldAttribIdentifier.varMarker.rawValue, stringValue: varMarker)

        worldElem.addAttribute(name: WorldAttribIdentifier.wildMarker.rawValue, stringValue: wildMarker)

        if let colorStr = foreColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.foreColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = backColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.backColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = linkColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.linkColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = echoBackColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.echoBackColor.rawValue, stringValue: "#\(colorStr)")
        }

        if let colorStr = intenseColor.toHex() {
            worldElem.addAttribute(name: WorldAttribIdentifier.intenseColor.rawValue, stringValue: "#\(colorStr)")
        }

        worldElem.addAttribute(name: WorldAttribIdentifier.font.rawValue, stringValue: fontName)

        worldElem.addAttribute(name: WorldAttribIdentifier.fontSize.rawValue, stringValue: "\(Int(fontSize))")

        worldElem.addAttribute(name: WorldAttribIdentifier.monoFont.rawValue, stringValue: monoFontName)

        worldElem.addAttribute(name: WorldAttribIdentifier.monoFontSize.rawValue, stringValue: "\(Int(monoFontSize))")

        worldElem.addAttribute(name: WorldAttribIdentifier.MCPFont.rawValue, stringValue: monoFontName)

        worldElem.addAttribute(name: WorldAttribIdentifier.MCPFontSize.rawValue, stringValue: "\(Int(monoFontSize))")

        worldElem.addAttribute(name: WorldAttribIdentifier.resolution.rawValue,
            stringValue: "\(outputRows)x\(columns)x\(inputRows)")

        worldElem.addAttribute(name: WorldAttribIdentifier.position.rawValue,
            stringValue: "\(Int(position.x)),\(Int(position.y))")

        worldElem.addAttribute(name: WorldAttribIdentifier.windowSize.rawValue,
            stringValue: "\(Int(windowSize.width)),\(Int(windowSize.height))")

        worldElem.addAttribute(name: WorldAttribIdentifier.zoomed.rawValue,
            stringValue: zoomed ? "TRUE" : "FALSE")

        worldElem.addAttribute(name: WorldAttribIdentifier.outputMax.rawValue, stringValue: String(outputMax))

        worldElem.addAttribute(name: WorldAttribIdentifier.outputMin.rawValue, stringValue: String(outputMin))

        worldElem.addAttribute(name: WorldAttribIdentifier.flushTicks.rawValue, stringValue: String(flushTicks))

        worldElem.addAttribute(name: WorldAttribIdentifier.retrySecs.rawValue, stringValue: String(retrySecs))

        worldElem.addAttribute(name: WorldAttribIdentifier.keepAliveMins.rawValue, stringValue: String(keepAliveMins))

        let triggersElem = try triggerMan.toXMLElement()
        if triggersElem.childCount > 0 {
            worldElem.addChild(triggersElem)
        }

        logger.info("XML data representation \(String(worldElem.xmlString))")
        return worldElem
    }
}
