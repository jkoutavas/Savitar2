//
//  SessionInputFocusTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import Cocoa
import XCTest

final class SessionInputFocusTests: XCTestCase {
    func testPlainTypingReclaimsFocus() {
        XCTAssertTrue(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [], characters: "a"))
        XCTAssertTrue(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [], characters: " "))
        XCTAssertTrue(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [.shift], characters: "A"))
        XCTAssertTrue(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [.option], characters: "å"))
    }

    func testCommandAndControlShortcutsDoNotReclaim() {
        XCTAssertFalse(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [.command], characters: "c"))
        XCTAssertFalse(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [.control], characters: "a"))
        XCTAssertFalse(SessionInputFocus.shouldReclaimForTyping(
            modifierFlags: [.command, .shift],
            characters: "c"
        ))
    }

    func testEmptyOrNilCharactersDoNotReclaim() {
        XCTAssertFalse(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [], characters: nil))
        XCTAssertFalse(SessionInputFocus.shouldReclaimForTyping(modifierFlags: [], characters: ""))
    }
}
