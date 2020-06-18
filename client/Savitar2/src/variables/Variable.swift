//
//  Variable.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/23/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let VariableElemIdentifier = "MACRO"

class Variable: SavitarObject {
    public static let defaultName = "<new macro>"
    public static let defaultValue = "<new value>"

    // default settings
    var enabled = true
    var readOnly = false
    var value = defaultValue
    var keySequence = ""

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    let ValueElemIdentifier = "VALUE"

    // These are the VariableElemIdentifier attributes
    enum VariableAttribIdentifier: String {
        case name = "NAME"
        case flags = "FLAGS"
        case key = "KEY"
    }

    override init() {
        super.init()

        name = Self.defaultName
    }

    override func parse(xml: XML.Accessor) throws {
        for attribute in xml.attributes {
            switch attribute.key {
            case VariableAttribIdentifier.name.rawValue:
                self.name = attribute.value
            case VariableAttribIdentifier.flags.rawValue:
                self.enabled = !attribute.value.contains("disabled")
                self.readOnly = attribute.value.contains("readOnly")
            case VariableAttribIdentifier.key.rawValue:
                self.keySequence = attribute.value
            default:
                print("skipping variable attribute \(attribute.key)")
            }
        }

        if let text = xml[ValueElemIdentifier].text {
             self.value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    override func toXMLElement() throws -> XMLElement {
        let varElem = XMLElement(name: VariableElemIdentifier)

        varElem.addAttribute(name: VariableAttribIdentifier.name.rawValue, stringValue: self.name)

        varElem.addAttribute(name: VariableAttribIdentifier.key.rawValue, stringValue: self.keySequence)

        var flags = !self.enabled ? "disabled" : ""
        if self.readOnly {
            if flags.count > 0 {
                flags = "\(flags)+"
            }
            flags = "\(flags)readOnly"
        }
        if flags.count > 0 {
            varElem.addAttribute(name: VariableAttribIdentifier.flags.rawValue, stringValue: flags)
        }

        varElem.addChild(XMLElement.init(name: ValueElemIdentifier, stringValue: value))

        return varElem
    }
}
