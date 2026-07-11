//
//  ClickerMan.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

let ClickerAliasesElemIdentifier = "ALIASES"
let ClickerAliasElemIdentifier = "ALIAS"

/// Macro Clicker slot bindings — v1 `CAliasMan` / `ALIAS` XML (Story 11).
class ClickerMan: SavitarXMLProtocol {
    private(set) var slots: [ClickerSlot]

    init(slots: [ClickerSlot]? = nil) {
        if let slots {
            self.slots = slots
        } else {
            self.slots = ClickerSlotID.allCases.map { ClickerSlot(id: $0) }
        }
    }

    func slot(for id: ClickerSlotID) -> ClickerSlot {
        slots[id.rawValue]
    }

    func setMacroName(_ name: String, for id: ClickerSlotID) {
        slots[id.rawValue].macroName = name
    }

    func parse(xml: XML.Accessor) throws {
        let aliasElems = xml[ClickerAliasesElemIdentifier][ClickerAliasElemIdentifier]
        var index = 0
        for elem in aliasElems {
            guard index < slots.count else { break }
            if let name = elem.attributes["NAME"] {
                slots[index].macroName = Self.normalizeLegacyBinding(name)
            }
            index += 1
        }
    }

    /// Upgrade early Savitar 2 factory prefs that used `MACRO-A` … `MACRO-F`.
    private static func normalizeLegacyBinding(_ name: String) -> String {
        guard name.count == 7, name.hasPrefix("MACRO-") else { return name }
        let letter = name.suffix(1)
        guard letter.rangeOfCharacter(from: .letters) != nil else { return name }
        return "MACRO_\(letter)"
    }

    func toXMLElement() throws -> XMLElement {
        let aliasesElem = XMLElement(name: ClickerAliasesElemIdentifier)
        for slot in slots {
            let aliasElem = XMLElement(name: ClickerAliasElemIdentifier)
            aliasElem.addAttribute(name: "NAME", stringValue: slot.macroName)
            aliasesElem.addChild(aliasElem)
        }
        return aliasesElem
    }
}
