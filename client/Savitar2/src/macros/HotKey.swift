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
    Keycode.delete: "del",  // Savitar 1.x legacy abbreviation
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

struct HotKey {
    var keyCode: KeyCodeType
    var modifierFlags: NSEvent.ModifierFlags

    init(keyLabel: String) {
        // we do a "bijective" dictionary lookup
        // https://stackoverflow.com/questions/27218669/swift-dictionary-get-key-for-value
        keyCode = 0
        if let key = KeyCodeLabelDict.first(where: { $0.value == keyLabel })?.key {
            keyCode = key
        }
        modifierFlags = NSEvent.ModifierFlags.init(rawValue: 0)
    }

    func toString() -> String {
        if let funcLabel = KeyCodeLabelDict[keyCode] {
            return funcLabel
        }

        return ""
    }
}
