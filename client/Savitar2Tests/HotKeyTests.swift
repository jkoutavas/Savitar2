//
//  HotKeyTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 7/5/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class HotKeyTests: XCTestCase {
    func testKeyCodeLabels() {
        XCTAssertEqual(HotKey(keyLabel: "up arrow").keyCode, Keycode.upArrow)
        XCTAssertEqual(HotKey(keyLabel: "down arrow").keyCode, Keycode.downArrow)
        XCTAssertEqual(HotKey(keyLabel: "left arrow").keyCode, Keycode.leftArrow)
        XCTAssertEqual(HotKey(keyLabel: "right arrow").keyCode, Keycode.rightArrow)
        XCTAssertEqual(HotKey(keyLabel: "F1").keyCode, Keycode.f1)
        XCTAssertEqual(HotKey(keyLabel: "F2").keyCode, Keycode.f2)
        XCTAssertEqual(HotKey(keyLabel: "F3").keyCode, Keycode.f3)
        XCTAssertEqual(HotKey(keyLabel: "F4").keyCode, Keycode.f4)
        XCTAssertEqual(HotKey(keyLabel: "F5").keyCode, Keycode.f5)
        XCTAssertEqual(HotKey(keyLabel: "F6").keyCode, Keycode.f6)
        XCTAssertEqual(HotKey(keyLabel: "F7").keyCode, Keycode.f7)
        XCTAssertEqual(HotKey(keyLabel: "F8").keyCode, Keycode.f8)
        XCTAssertEqual(HotKey(keyLabel: "F9").keyCode, Keycode.f9)
        XCTAssertEqual(HotKey(keyLabel: "F10").keyCode, Keycode.f10)
        XCTAssertEqual(HotKey(keyLabel: "F11").keyCode, Keycode.f11)
        XCTAssertEqual(HotKey(keyLabel: "F12").keyCode, Keycode.f12)
        XCTAssertEqual(HotKey(keyLabel: "F13").keyCode, Keycode.f13)
        XCTAssertEqual(HotKey(keyLabel: "F14").keyCode, Keycode.f14)
        XCTAssertEqual(HotKey(keyLabel: "F15").keyCode, Keycode.f15)
        XCTAssertEqual(HotKey(keyLabel: "F16").keyCode, Keycode.f16)
        XCTAssertEqual(HotKey(keyLabel: "F17").keyCode, Keycode.f17)
        XCTAssertEqual(HotKey(keyLabel: "F18").keyCode, Keycode.f18)
        XCTAssertEqual(HotKey(keyLabel: "F19").keyCode, Keycode.f19)
        XCTAssertEqual(HotKey(keyLabel: "F20").keyCode, Keycode.f20)
        XCTAssertEqual(HotKey(keyLabel: "del").keyCode, Keycode.delete)
        XCTAssertEqual(HotKey(keyLabel: "home").keyCode, Keycode.home)
        XCTAssertEqual(HotKey(keyLabel: "end").keyCode, Keycode.end)
        XCTAssertEqual(HotKey(keyLabel: "page up").keyCode, Keycode.pageUp)
        XCTAssertEqual(HotKey(keyLabel: "page down").keyCode, Keycode.pageDown)
        XCTAssertEqual(HotKey(keyLabel: "KPenter").keyCode, Keycode.keypadEnter)
        XCTAssertEqual(HotKey(keyLabel: "KP.").keyCode, Keycode.keypadDecimal)
        XCTAssertEqual(HotKey(keyLabel: "KP*").keyCode, Keycode.keypadMultiply)
        XCTAssertEqual(HotKey(keyLabel: "KP+").keyCode, Keycode.keypadPlus)
        XCTAssertEqual(HotKey(keyLabel: "KP/").keyCode, Keycode.keypadDivide)
        XCTAssertEqual(HotKey(keyLabel: "KP-").keyCode, Keycode.keypadMinus)
        XCTAssertEqual(HotKey(keyLabel: "KP=").keyCode, Keycode.keypadEquals)

        XCTAssertEqual(HotKey(keyLabel: "KPenter").keyCode, Keycode.keypadEnter)
        XCTAssertEqual(HotKey(keyLabel: "KP.").keyCode, Keycode.keypadDecimal)
        XCTAssertEqual(HotKey(keyLabel: "KP*").keyCode, Keycode.keypadMultiply)
        XCTAssertEqual(HotKey(keyLabel: "KP+").keyCode, Keycode.keypadPlus)
        XCTAssertEqual(HotKey(keyLabel: "KP/").keyCode, Keycode.keypadDivide)
        XCTAssertEqual(HotKey(keyLabel: "KP-").keyCode, Keycode.keypadMinus)
        XCTAssertEqual(HotKey(keyLabel: "KP=").keyCode, Keycode.keypadEquals)
        XCTAssertEqual(HotKey(keyLabel: "KP0").keyCode, Keycode.keypad0)
        XCTAssertEqual(HotKey(keyLabel: "KP1").keyCode, Keycode.keypad1)
        XCTAssertEqual(HotKey(keyLabel: "KP2").keyCode, Keycode.keypad2)
        XCTAssertEqual(HotKey(keyLabel: "KP3").keyCode, Keycode.keypad3)
        XCTAssertEqual(HotKey(keyLabel: "KP4").keyCode, Keycode.keypad4)
        XCTAssertEqual(HotKey(keyLabel: "KP5").keyCode, Keycode.keypad5)
        XCTAssertEqual(HotKey(keyLabel: "KP6").keyCode, Keycode.keypad6)
        XCTAssertEqual(HotKey(keyLabel: "KP7").keyCode, Keycode.keypad7)
        XCTAssertEqual(HotKey(keyLabel: "KP8").keyCode, Keycode.keypad8)
        XCTAssertEqual(HotKey(keyLabel: "KP9").keyCode, Keycode.keypad9)
    }
}
