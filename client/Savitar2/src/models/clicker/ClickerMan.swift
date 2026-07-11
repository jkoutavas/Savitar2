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
                slots[index].macroName = name
            }
            index += 1
        }
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
