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
    ] }
    static var labelDict: [String: Self] { return [
        "ansi": .ansi,
        "echoCmds": .echoCmds,
        "echoCR": .echoCR,
        "html": .html
    ] }
}

enum IntensityType: Int {
    case auto
    case bold
    case color
}

class World: SavitarObject, NSCopying {
    // KVO-based world settings with their defaults
    @objc dynamic var editable = true

    @objc dynamic var port: UInt32 = 0
    @objc dynamic var host = ""

    @objc dynamic var telnetString: String {
        get {
            host.count > 0 ? "\(TelnetIdentifier)\(host):\(port)" : ""
        }
        set {
            let body = newValue.dropPrefix(TelnetIdentifier)
            let parts = body.components(separatedBy: ":")
            if parts.count == 2 {
                host = parts[0]
                guard let p1 = UInt32(parts[1]) else { return }
                port = p1
            } else if parts.count == 4 {
                // might have ::1 as the host
                host = "localhost"
                guard let p3 = UInt32(parts[3]) else { return }
                port = p3
            }
        }
    }

    @objc dynamic var logonCmd = ""
    @objc dynamic var logoffCmd = ""

    @objc dynamic var cmdMarker = "##"
    @objc dynamic var varMarker = "%%"
    @objc dynamic var wildMarker = "$$"
    @objc dynamic var backColor = NSColor(hex: "#666699")!
    @objc dynamic var foreColor = NSColor.white
    @objc dynamic var linkColor = NSColor.blue
    @objc dynamic var echoBackColor = NSColor(hex: "9CA6FF")!
    @objc dynamic var intenseColor = NSColor.white
    @objc dynamic var fontName = "Monaco"
    @objc dynamic var fontSize: CGFloat = 9
    @objc dynamic var monoFontName = "Monaco"
    @objc dynamic var monoFontSize: CGFloat = 9
    @objc dynamic var MCPFontName = "Monaco"
    @objc dynamic var MCPFontSize: CGFloat = 9

    @objc dynamic var inputRows = 2
    @objc dynamic var outputRows = 24
    @objc dynamic var columns = 80
    @objc dynamic var position = NSPoint(x: 44, y: 0)
    @objc dynamic var windowSize = NSSize(width: 480, height: 270)
    @objc dynamic var zoomed = false

    // v1.0 settings currently not in use in v2.0
    @objc dynamic var outputMax = 100 * 1024
    @objc dynamic var outputMin = 25 * 1024
    @objc dynamic var flushTicks = 30
    @objc dynamic var retrySecs = 0
    @objc dynamic var keepAliveMins = 0

    @objc dynamic var ansiEnabled: Bool {
        get { flags.contains(.ansi) }
        set(enabled) {
            if enabled {
                flags.insert(.ansi)
            } else {
                flags.remove(.ansi)
            }
        }
    }

    @objc dynamic var htmlEnabled: Bool {
        get { flags.contains(.html) }
        set(enabled) {
            if enabled {
                flags.insert(.html)
            } else {
                flags.remove(.html)
            }
        }
    }

    // new v2.0 settings
    @objc enum LoggingType: Int {
        case append
        case overwrite
    }
    var logfilePath = ""
    @objc dynamic var loggingEnabled: ObjCBool = false
    @objc dynamic var loggingType = LoggingType.append

    var flags: WorldFlags = [.ansi, .html]
    var intensityType: IntensityType = .auto

    var macroMan = MacroMan()
    var triggerMan = TriggerMan()

    init(world: World) {
        super.init()

        port = world.port
        host = world.host
        name = world.name
        flags = world.flags
        cmdMarker = world.cmdMarker
        varMarker = world.varMarker
        wildMarker = world.wildMarker
        backColor = world.backColor
        foreColor = world.foreColor
        linkColor = world.linkColor
        echoBackColor = world.echoBackColor
        intenseColor = world.intenseColor
        intensityType = world.intensityType
        fontName = world.fontName
        fontSize = world.fontSize
        monoFontName = world.monoFontName
        monoFontSize = world.monoFontSize
        MCPFontName = world.MCPFontName
        MCPFontSize = world.MCPFontSize
        inputRows = world.inputRows
        columns = world.columns
        position = world.position
        windowSize = world.windowSize
        zoomed = world.zoomed
        outputMax = world.outputMax
        outputMin = world.outputMin
        flushTicks = world.flushTicks
        retrySecs = world.retrySecs
        keepAliveMins = world.keepAliveMins
        logonCmd = world.logonCmd
        logoffCmd = world.logoffCmd

        // new v2.0 settings
        logfilePath = world.logfilePath
        loggingEnabled = world.loggingEnabled
        loggingType = world.loggingType
    }

    override init() {
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func copy(with _: NSZone? = nil) -> Any {
        return World(world: self)
    }

    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

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
        case URL
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

        // new with V2
        case logfilePath = "LOGFILEPATH"
        case loggingEnabled = "LOGGINGENABLED"
        case loggingType = "LOGGINGTYPE"
    }

    let intensityLabelDict: [String: IntensityType] = [
         "auto": .auto,
         "bold": .bold,
         "color": .color
     ]

     let loggingLabelDict: [String: LoggingType] = [
         "append": .append,
         "overwrite": .overwrite
     ]

    override func parse(xml: XML.Accessor) throws {
         for attribute in xml.attributes {
            switch attribute.key {
            case WorldAttribIdentifier.name.rawValue:
                name = attribute.value

            case WorldAttribIdentifier.URL.rawValue:
                if attribute.value.hasPrefix(TelnetIdentifier) {
                    telnetString = attribute.value
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
                if let type = intensityLabelDict[attribute.value] {
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

            // new with V2
            case WorldAttribIdentifier.logfilePath.rawValue:
                 logfilePath = attribute.value
            case WorldAttribIdentifier.loggingEnabled.rawValue:
                loggingEnabled = ObjCBool(attribute.value == "TRUE")
            case WorldAttribIdentifier.loggingType.rawValue:
                 loggingType = .append
                 if let type = loggingLabelDict[attribute.value] {
                     loggingType = type
                 }

            default:
                print("skipping world XML attribute \(attribute.key)")
            }
        }

        if let text = xml[LogonCmdElemIdentifier].text {
            logonCmd = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[LogoffCmdElemIdentifier].text {
            logoffCmd = text.trimmingCharacters(in: .whitespacesAndNewlines)
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

        worldElem.addAttribute(name: WorldAttribIdentifier.URL.rawValue, stringValue: telnetString)

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

        // TODO: intenseType not being written (and is not used)

        worldElem.addAttribute(name: WorldAttribIdentifier.logfilePath.rawValue,
             stringValue: logfilePath)
        worldElem.addAttribute(name: WorldAttribIdentifier.loggingEnabled.rawValue,
                               stringValue: loggingEnabled.boolValue ? "TRUE" : "FALSE")
        worldElem.addAttribute(name: WorldAttribIdentifier.loggingType.rawValue,
             stringValue: loggingLabelDict.key(from: loggingType)!)

        if logonCmd.count > 0 {
            worldElem.addChild(XMLElement(name: LogonCmdElemIdentifier, stringValue:
                logonCmd))
        }

        if logoffCmd.count > 0 {
            worldElem.addChild(XMLElement(name: LogoffCmdElemIdentifier, stringValue: logoffCmd))
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
