//
//  ClickerSlot.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

/// Fixed Macro Clicker palette slot (v1 directions + grid; Story 11).
enum ClickerSlotID: Int, CaseIterable {
    case north = 0
    case northeast
    case east
    case southeast
    case south
    case southwest
    case west
    case northwest
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case eleven
    case twelve
    case thirteen
    case fourteen
    case fifteen

    static let directionSlots: [ClickerSlotID] = [
        .north, .northeast, .east, .southeast, .south, .southwest, .west, .northwest
    ]

    /// Grid order matches Clicker layout: 1–9 then a–f.
    static let gridSlots: [ClickerSlotID] = [
        .one, .two, .three, .four, .five, .six, .seven, .eight, .nine,
        .ten, .eleven, .twelve, .thirteen, .fourteen, .fifteen
    ]

    /// Whimsical face label on the grid button (v1 cicn art used letters on the bottom row).
    var whimsicalLabel: String {
        switch self {
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "a"
        case .eleven: return "b"
        case .twelve: return "c"
        case .thirteen: return "d"
        case .fourteen: return "e"
        case .fifteen: return "f"
        default: return ""
        }
    }

    /// Factory default macro name for this button slot.
    var defaultMacroName: String {
        switch self {
        case .north: return "MACRO_NORTH"
        case .northeast: return "MACRO_NEAST"
        case .east: return "MACRO_EAST"
        case .southeast: return "MACRO_SEAST"
        case .south: return "MACRO_SOUTH"
        case .southwest: return "MACRO_SWEST"
        case .west: return "MACRO_WEST"
        case .northwest: return "MACRO_NWEST"
        case .one: return "MACRO_1"
        case .two: return "MACRO_2"
        case .three: return "MACRO_3"
        case .four: return "MACRO_4"
        case .five: return "MACRO_5"
        case .six: return "MACRO_6"
        case .seven: return "MACRO_7"
        case .eight: return "MACRO_8"
        case .nine: return "MACRO_9"
        case .ten: return "MACRO_A"
        case .eleven: return "MACRO_B"
        case .twelve: return "MACRO_C"
        case .thirteen: return "MACRO_D"
        case .fourteen: return "MACRO_E"
        case .fifteen: return "MACRO_F"
        }
    }

    var isDirection: Bool {
        Self.directionSlots.contains(self)
    }

    var isGrid: Bool {
        Self.gridSlots.contains(self)
    }
}

struct ClickerSlot: Equatable {
    let id: ClickerSlotID
    var macroName: String

    init(id: ClickerSlotID, macroName: String? = nil) {
        self.id = id
        self.macroName = macroName ?? id.defaultMacroName
    }
}
