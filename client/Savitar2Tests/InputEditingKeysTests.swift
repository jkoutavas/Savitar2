//
//  InputEditingKeysTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import Cocoa
import XCTest

class InputEditingKeysTests: XCTestCase {
    func testUnmodifiedArrowKeys() {
        XCTAssertEqual(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.leftArrow)), .moveLeft)
        XCTAssertEqual(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.rightArrow)), .moveRight)
    }

    func testModifiedArrowKeysAreIgnored() {
        XCTAssertNil(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.leftArrow, modifiers: .shift)))
        XCTAssertNil(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.rightArrow, modifiers: .control)))
    }

    func testControlAAndC() {
        XCTAssertEqual(
            InputEditingKeys.action(for: keyEvent(keyCode: Keycode.a, modifiers: .control)),
            .beginningOfLine
        )
        XCTAssertEqual(
            InputEditingKeys.action(for: keyEvent(keyCode: Keycode.c, modifiers: .control)),
            .sendInterrupt
        )
    }

    func testControlGIsBellInput() {
        XCTAssertEqual(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.g, modifiers: .control)), .sendBell)
    }

    func testCommandAIsNotBeginningOfLine() {
        XCTAssertNil(InputEditingKeys.action(for: keyEvent(keyCode: Keycode.a, modifiers: .command)))
    }

    private func keyEvent(keyCode: UInt16, modifiers: NSEvent.ModifierFlags = []) -> NSEvent {
        return NSEvent.keyEvent(with: .keyDown,
                                location: .zero,
                                modifierFlags: modifiers,
                                timestamp: 0,
                                windowNumber: 0,
                                context: nil,
                                characters: "",
                                charactersIgnoringModifiers: "",
                                isARepeat: false,
                                keyCode: keyCode)!
    }
}
