//
//  TerminalBellTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import AppKit
import XCTest

class TerminalBellTests: XCTestCase {
    override func tearDown() {
        TerminalBell.playSound = { NSSound.beep() }
        super.tearDown()
    }

    func testStripsBellCharacters() {
        XCTAssertEqual(TerminalBell.process("hello\u{7}world", muted: true), "helloworld")
    }

    func testPlaysBellWhenNotMuted() {
        var beepCount = 0
        TerminalBell.playSound = { beepCount += 1 }

        XCTAssertEqual(TerminalBell.process("a\u{7}b\u{7}c", muted: false), "abc")
        XCTAssertEqual(beepCount, 2)
    }

    func testDoesNotPlayBellWhenMuted() {
        var beepCount = 0
        TerminalBell.playSound = { beepCount += 1 }

        XCTAssertEqual(TerminalBell.process("\u{7}", muted: true), "")
        XCTAssertEqual(beepCount, 0)
    }

    func testLeavesTextWithoutBellUntouched() {
        XCTAssertEqual(TerminalBell.process("plain text", muted: false), "plain text")
    }
}
