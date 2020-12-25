//
//  Macro.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/23/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let MacroElemIdentifier = "MACRO"

class Macro: SavitarObject {
    public static let defaultName = "<new macro>"
    public static let defaultValue = "<new value>"

    var enabled: Bool
    var hotKey = HotKey(keyLabel: "")
    var keyLabel: String {
        get {
            return hotKey.toString()
        }
        set(value) {
            hotKey = HotKey(keyLabel: value)
        }
    }

    var readOnly: Bool
    var value: String

    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

    let ValueElemIdentifier = "VALUE"

    // These are the MacroElemIdentifier attributes
    enum MacroAttribIdentifier: String {
        case name = "NAME"
        case flags = "FLAGS"
        case key = "KEY"
    }

    override init() {
        enabled = true
        readOnly = false
        value = Self.defaultValue

        super.init()

        name = Self.defaultName
        keyLabel = ""
    }

    override func parse(xml: XML.Accessor) throws {
        for attribute in xml.attributes {
            switch attribute.key {
            case MacroAttribIdentifier.name.rawValue:
                name = attribute.value
            case MacroAttribIdentifier.flags.rawValue:
                enabled = !attribute.value.contains("disabled")
                readOnly = attribute.value.contains("readOnly")
            case MacroAttribIdentifier.key.rawValue:
                keyLabel = attribute.value
            default:
                print("skipping macro attribute \(attribute.key)")
            }
        }

        if let text = xml[ValueElemIdentifier].text {
            value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    override func toXMLElement() throws -> XMLElement {
        let varElem = XMLElement(name: MacroElemIdentifier)

        varElem.addAttribute(name: MacroAttribIdentifier.name.rawValue, stringValue: name)

        varElem.addAttribute(name: MacroAttribIdentifier.key.rawValue, stringValue: keyLabel)

        var flags = !enabled ? "disabled" : ""
        if readOnly {
            if flags.count > 0 {
                flags = "\(flags)+"
            }
            flags = "\(flags)readOnly"
        }
        if flags.count > 0 {
            varElem.addAttribute(name: MacroAttribIdentifier.flags.rawValue, stringValue: flags)
        }

        varElem.addChild(XMLElement(name: ValueElemIdentifier, stringValue: value))

        return varElem
    }

    // stackoverflow.com/questions/6084266/check-modifierflags-of-nsevent-if-a-certain-modifier-was-pressed-but-no-other
    func isHotKey(forEvent event: NSEvent) -> Bool {
        return enabled && hotKey.keyCode != 0 && hotKey.keyCode == event.keyCode &&
            hotKey.modifierFlags.intersection(.deviceIndependentFlagsMask) ==
            event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    }
}
