//
//  HotKey.swift
//  Savitar2
//
//  Created by Jay Koutavas on 7/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

typealias KeyCodeType = UInt16 // the type of NSEvent.keyCode

let KeyCodeLabelDict: [KeyCodeType: String] = [
    Keycode.upArrow: "up arrow",
    Keycode.downArrow: "down arrow",
    Keycode.leftArrow: "left arrow",
    Keycode.rightArrow: "right arrow",
    Keycode.escape: "escape",
    Keycode.f1: "F1",
    Keycode.f2: "F2",
    Keycode.f3: "F3",
    Keycode.f4: "F4",
    Keycode.f5: "F5",
    Keycode.f6: "F6",
    Keycode.f7: "F7",
    Keycode.f8: "F8",
    Keycode.f9: "F9",
    Keycode.f10: "F10",
    Keycode.f11: "F11",
    Keycode.f12: "F12",
    Keycode.f13: "F13",
    Keycode.f14: "F14",
    Keycode.f15: "F15",
    Keycode.f16: "F16",
    Keycode.f17: "F17",
    Keycode.f18: "F18",
    Keycode.f19: "F19",
    Keycode.f20: "F20",
    Keycode.delete: "del", // Savitar 1.x legacy abbreviation
    Keycode.home: "home",
    Keycode.end: "end",
    Keycode.pageUp: "page up",
    Keycode.pageDown: "page down",
    Keycode.keypadEnter: "KPenter",
    Keycode.keypadDecimal: "KP.",
    Keycode.keypadMultiply: "KP*",
    Keycode.keypadPlus: "KP+",
    Keycode.keypadDivide: "KP/",
    Keycode.keypadMinus: "KP-",
    Keycode.keypadEquals: "KP=",
    Keycode.keypad0: "KP0",
    Keycode.keypad1: "KP1",
    Keycode.keypad2: "KP2",
    Keycode.keypad3: "KP3",
    Keycode.keypad4: "KP4",
    Keycode.keypad5: "KP5",
    Keycode.keypad6: "KP6",
    Keycode.keypad7: "KP7",
    Keycode.keypad8: "KP8",
    Keycode.keypad9: "KP9",
    Keycode.keypadClear: "clear"
]

struct HotKey: Equatable {
    var keyCode: KeyCodeType
    var modifierFlags: NSEvent.ModifierFlags
    internal var chars: String

    init(event: NSEvent) {
        keyCode = event.keyCode
        modifierFlags = event.modifierFlags
        chars = event.charactersIgnoringModifiers!
    }

    static func handleFlag(_ keyLabel: inout String, _ modString: String, _ flag: NSEvent.ModifierFlags,
                           _ flags: NSEvent.ModifierFlags) -> NSEvent.ModifierFlags {
        var result = flags
        if keyLabel.contains(modString) {
            keyLabel = keyLabel.replacingOccurrences(of: modString, with: "")
            result.insert(flag)
            return result
        }

        return result
    }

    mutating func raiseFlag(keyLabel: String, modString: String, flag: NSEvent.ModifierFlags) -> String {
        if keyLabel.contains(modString) {
            modifierFlags.insert(flag)
            return keyLabel.replacingOccurrences(of: modString, with: "")
        }

        return keyLabel
    }

    init(keyLabel: String) {
        var label = keyLabel

        modifierFlags = NSEvent.ModifierFlags(rawValue: 0)
        modifierFlags = HotKey.handleFlag(&label, "shift-", .shift, modifierFlags)
        modifierFlags = HotKey.handleFlag(&label, "control-", .control, modifierFlags)
        modifierFlags = HotKey.handleFlag(&label, "option-", .option, modifierFlags)
        modifierFlags = HotKey.handleFlag(&label, "command-", .command, modifierFlags)

        // we do a "bijective" dictionary lookup
        // https://stackoverflow.com/questions/27218669/swift-dictionary-get-key-for-value
        keyCode = 0
        if let key = KeyCodeLabelDict.first(where: { $0.value == label })?.key {
            keyCode = key
        }

        // whatever remains of label are the visible characters for this HotKey
        chars = label
    }

    static func normalize(modifierFlags: NSEvent.ModifierFlags) -> NSEvent.ModifierFlags {
        var flags = modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.function) {
            flags.remove(.function)
        }
        if flags.contains(.numericPad) {
            flags.remove(.numericPad)
        }
        return flags
    }

    static func isPrintable(_ chars: String) -> Bool {
        let utf8View = chars.utf8
        return utf8View.count == 1 && utf8View.first! > 32 && utf8View.first! < 127
    }

    func toString() -> String {
        var keyLabel = ""
        if let keyString = KeyCodeLabelDict[keyCode] {
            keyLabel = keyString
        } else if HotKey.isPrintable(chars) {
            keyLabel = chars
        } else {
            return ""
        }
        var modifierLabel = ""

        switch HotKey.normalize(modifierFlags: modifierFlags) {
        case [.shift]:
            modifierLabel = "shift-"
        case [.control]:
            modifierLabel = "control-"
        case [.option]:
            modifierLabel = "option-"
        case [.command]:
            modifierLabel = "command-"
        case [.control, .shift]:
            modifierLabel = "control-shift-"
        case [.option, .shift]:
            modifierLabel = "option-shift-"
        case [.command, .shift]:
            modifierLabel = "command-shift-"
        case [.control, .option]:
            modifierLabel = "control-option-"
        case [.control, .command]:
            modifierLabel = "control-command-"
        case [.option, .command]:
            modifierLabel = "option-command-"
        case [.shift, .control, .option]:
            modifierLabel = "shift-control-option-"
        case [.shift, .control, .command]:
            modifierLabel = "shift-control-command-"
        case [.control, .option, .command]:
            modifierLabel = "control-option-command-"
        case [.shift, .command, .option]:
            modifierLabel = "shift-command-option-"
        case [.shift, .control, .option, .command]:
            modifierLabel = "shift-control-option-command"
        default:
            modifierLabel = ""
        }

        return "\(modifierLabel)\(keyLabel)"
    }

    func isKnown() -> Bool {
        return KeyCodeLabelDict[keyCode] != nil || (HotKey.isPrintable(chars) &&
            (modifierFlags.contains(.control) || modifierFlags.contains(.option) || modifierFlags.contains(.command)))
    }

    static func == (lhs: HotKey, rhs: HotKey) -> Bool {
        return lhs.keyCode == rhs.keyCode &&
            normalize(modifierFlags: lhs.modifierFlags) == normalize(modifierFlags: rhs.modifierFlags)
    }
}
