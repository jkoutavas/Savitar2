//
//  SavColor.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let ColorElemIdentifier = "COLOR"

class SavColor: NSObject, SavitarXMLProtocol {

    var name = ""
    var color: NSColor?

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    // These are the ColorElemIdentifier attributes
    enum ColorAttribIdentifier: String {
        case name = "NAME"
        case rgb = "RGB"
    }

    func parse(xml: XML.Accessor) throws {
        for attribute in xml.attributes {
            switch attribute.key {
            case ColorAttribIdentifier.name.rawValue:
                self.name = attribute.value
            case ColorAttribIdentifier.rgb.rawValue:
                self.color = NSColor.init(hex: attribute.value)
            default:
                print("skipping color attribute \(attribute.key)")
            }
        }
    }

    func toXMLElement() throws -> XMLElement {
        let colorElem = XMLElement(name: ColorElemIdentifier)

        if let colorStr = self.color?.toHex() {
            colorElem.addAttribute(name: ColorAttribIdentifier.name.rawValue, stringValue: self.name)

            colorElem.addAttribute(name: ColorAttribIdentifier.rgb.rawValue, stringValue: "#\(colorStr)")
        }

        return colorElem
    }
}
