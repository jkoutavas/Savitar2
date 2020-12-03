//
//  World.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 1997-2018 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let WorldElemIdentifier = "WORLD"

struct WorldFlags: OptionSet, Hashable {
    let rawValue: Int

    static let ansi = WorldFlags(rawValue: 1 << 0)
    static let echoCmds = WorldFlags(rawValue: 1 << 1)
    static let echoCR = WorldFlags(rawValue: 1 << 2)
    static let html = WorldFlags(rawValue: 1 << 3)
}
extension WorldFlags: StrOptionSet {
    // TODO: I wonder if there's a DRY-er way to do these
    static var labels: [Label] { return [
        (.ansi, "ansi"),
        (.echoCmds, "echoCmds"),
        (.echoCR, "echoCR"),
        (.html, "html")
        ]}
    static var labelDict: [String: Self] { return [
        "ansi": .ansi,
        "echoCmds": .echoCmds,
        "echoCR": .echoCR,
        "html": .html
        ]}
}

enum IntensityType: Int {
    case auto
    case bold
    case color
}

class World: SavitarObject, NSCopying {
    // KVO-based world settings with their defaults
    @objc dynamic var editable = true

    // TODO: just some hard-coded connection settings right now
    var port: UInt32 = 1337
    var host = "::1"

    var logonCmd = ""
    var logoffCmd = ""

    var cmdMarker = "##"
    var varMarker = "%%"
    var wildMarker = "$$"
    var backColor = NSColor.white
    var foreColor = NSColor.black
    var linkColor = NSColor.blue
    var echoBackColor = NSColor.init(hex: "9CA6FF")!
    var intenseColor = NSColor.white
    var fontName = "Monaco"
    var fontSize: CGFloat = 9
    var monoFontName = "Monaco"
    var monoFontSize: CGFloat = 9
    var MCPFontName = "Monaco"
    var MCPFontSize: CGFloat = 9

    var flags: WorldFlags = [.ansi, .html]
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

    var macroMan = MacroMan()
    var triggerMan = TriggerMan()

    init(world: World) {
        super.init()

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
        self.logonCmd = world.logonCmd
        self.logoffCmd = world.logoffCmd
    }

    override init() {
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
    let LogonCmdElemIdentifier = "LOGONCMD"
    let LogoffCmdElemIdentifier = "LOGOFFCMD"

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
    }

    override func parse(xml: XML.Accessor) throws {
        let intensityLabels: [String: IntensityType] = [
            "auto": .auto,
            "bold": .bold,
            "color": .color
        ]

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
                    } else if parts.count == 4 {
                        // might have ::1 as the host
                        host = "localhost"
                        guard let p3 = UInt32(parts[3]) else { break }
                        port = p3
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

            case WorldAttribIdentifier.logoffCmd.rawValue:
                logoffCmd = attribute.value

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

            default:
                print("skipping world XML attribute \(attribute.key)")
            }
        }

        if let text = xml[LogonCmdElemIdentifier].text {
             self.logonCmd = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[LogoffCmdElemIdentifier].text {
             self.logoffCmd = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if case .singleElement = xml[TriggersElemIdentifier] {
            try triggerMan.parse(xml: xml)
        }

        if case .singleElement = xml[MacrosElemIdentifier] {
            try macroMan.parse(xml: xml)
        }
    }

    override func toXMLElement() throws -> XMLElement {
        let worldElem = XMLElement(name: WorldElemIdentifier)

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

        if self.logonCmd.count > 0 {
            worldElem.addChild(XMLElement.init(name: LogonCmdElemIdentifier, stringValue:
                self.logonCmd))
        }

        if self.logoffCmd.count > 0 {
            worldElem.addChild(XMLElement.init(name: LogoffCmdElemIdentifier, stringValue: self.logoffCmd))
        }

        let triggersElem = try triggerMan.toXMLElement()
        if triggersElem.childCount > 0 {
            worldElem.addChild(triggersElem)
        }

        let macrosElem = try macroMan.toXMLElement()
        if macrosElem.childCount > 0 {
            worldElem.addChild(macrosElem)
        }

        return worldElem
    }
}
