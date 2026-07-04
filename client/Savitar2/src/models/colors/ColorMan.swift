//
//  ColorMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import AppKit
import SwiftyXMLParser

let ColorsElemIdentifier = "COLORS"

class ColorMan: ModelManager<SavColor>, SavitarXMLProtocol {
    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

    func parse(xml: XML.Accessor) throws {
        for elem in xml[ColorsElemIdentifier][ColorElemIdentifier] {
            let object = SavColor()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: ColorsElemIdentifier)
    }

    // MARK: - ANSI palette access

    // The stored color for a name, falling back to the Savitar 1 default when unset.
    func color(named name: String) -> NSColor {
        if let stored = get().first(where: { $0.name == name })?.color {
            return stored
        }
        return AnsiPalette.defaultColor(named: name)
    }

    // Update an existing color in place, or add a new one when the name is unknown.
    func setColor(_ color: NSColor, named name: String) {
        if let existing = get().first(where: { $0.name == name }) {
            existing.color = color
        } else {
            let savColor = SavColor()
            savColor.name = name
            savColor.color = color
            add(savColor)
        }
    }

    // Seed the full 24-color ANSI palette when nothing has been loaded (fresh install,
    // no Savitar 1 preferences to import).
    func installDefaultsIfNeeded() {
        guard get().isEmpty else { return }
        restoreDefaults()
    }

    // Reset every ANSI color to its Savitar 1 factory default.
    func restoreDefaults() {
        for name in AnsiPalette.allNames {
            setColor(AnsiPalette.defaultColor(named: name), named: name)
        }
    }
}
