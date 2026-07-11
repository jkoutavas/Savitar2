//
//  SessionLocalCommandsTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class SessionLocalCommandsTests: XCTestCase {
    func testParseSetStatusOutput() {
        XCTAssertEqual(
            SessionLocalCommands.parse("set status output Hello world"),
            .setStatus(pane: .output, message: "Hello world")
        )
    }

    func testParseSetStatusInputPreservesMessageCasing() {
        XCTAssertEqual(
            SessionLocalCommands.parse("SET Status INPUT HP: %%hitpoints"),
            .setStatus(pane: .input, message: "HP: %%hitpoints")
        )
    }

    func testParseCloseStats() {
        XCTAssertEqual(SessionLocalCommands.parse("close stats"), .closeStats)
        XCTAssertEqual(SessionLocalCommands.parse("close"), .unknown(body: "close"))
    }

    func testParseCloseStatusPane() {
        XCTAssertEqual(SessionLocalCommands.parse("close status output"), .closeStatus(pane: .output))
        XCTAssertEqual(SessionLocalCommands.parse("close status input"), .closeStatus(pane: .input))
    }

    func testParseExistingCommands() {
        XCTAssertEqual(SessionLocalCommands.parse("dump"), .dump)
        XCTAssertEqual(SessionLocalCommands.parse("history"), .history)
    }

    func testParseDumpListings() {
        XCTAssertEqual(SessionLocalCommands.parse("dump colors"), .dumpListing(.colors))
        XCTAssertEqual(SessionLocalCommands.parse("dump macros"), .dumpListing(.macros))
        XCTAssertEqual(SessionLocalCommands.parse("dump triggers"), .dumpListing(.triggers))
        XCTAssertEqual(SessionLocalCommands.parse("dump worlds"), .dumpListing(.worlds))
    }

    func testParseWorldFlags() {
        XCTAssertEqual(SessionLocalCommands.parse("set ansi on"), .setWorldFlag(.ansi, enabled: true))
        XCTAssertEqual(SessionLocalCommands.parse("set html off"), .setWorldFlag(.html, enabled: false))
        XCTAssertEqual(SessionLocalCommands.parse("set echo on"), .setWorldFlag(.echo, enabled: true))
        XCTAssertEqual(SessionLocalCommands.parse("set cronly off"), .setWorldFlag(.cronly, enabled: false))
        XCTAssertEqual(SessionLocalCommands.parse("set autoclose on"), .setWorldFlag(.autoclose, enabled: true))
    }

    func testParseSetScratchVariable() {
        XCTAssertEqual(
            SessionLocalCommands.parse("set macro \"hp\" 42"),
            .setScratchVariable(name: "hp", value: "42")
        )
    }

    func testParseSetMarker() {
        XCTAssertEqual(
            SessionLocalCommands.parse("set marker command //"),
            .setMarker(kind: .command, value: "//")
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("set marker wildcard $$"),
            .setMarker(kind: .wildcard, value: "$$")
        )
    }

    func testParseRecallAndBangRecall() {
        XCTAssertEqual(SessionLocalCommands.parse("recall 3"), .recall(index: 3))
        XCTAssertEqual(SessionLocalCommands.parse("!2"), .recall(index: 2))
    }

    func testParseBroadcastClearAndWait() {
        XCTAssertEqual(SessionLocalCommands.parse("broadcast say hello"), .broadcast(command: "say hello"))
        XCTAssertEqual(SessionLocalCommands.parse("clear screen"), .clearScreen)
        XCTAssertEqual(SessionLocalCommands.parse("capture"), .capture)
        XCTAssertEqual(SessionLocalCommands.parse("capture extra"), .unknown(body: "capture extra"))
        XCTAssertEqual(
            SessionLocalCommands.parse("wait 5 look"),
            .wait(seconds: 5, followUp: "look")
        )
        XCTAssertEqual(SessionLocalCommands.parse("wait 2"), .wait(seconds: 2, followUp: nil))
    }

    func testParseTriggerEnableDisable() {
        XCTAssertEqual(
            SessionLocalCommands.parse("enable trigger \"Gag spam\""),
            .enableTrigger(name: "Gag spam")
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("enable trigger beep"),
            .enableTrigger(name: "beep")
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("disable trigger \"Gag spam\""),
            .disableTrigger(name: "Gag spam")
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("disable trigger beep"),
            .disableTrigger(name: "beep")
        )
    }

    func testParseRegex() {
        XCTAssertEqual(
            SessionLocalCommands.parse("regex \"abc123\" \"[0-9]+\""),
            .regex(testString: "abc123", pattern: "[0-9]+")
        )
    }

    func testParseLink() {
        XCTAssertEqual(
            SessionLocalCommands.parse("link <https://example.com>"),
            .link(url: "https://example.com", label: "https://example.com", colorHex: nil)
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("link <https://example.com> \"Example\""),
            .link(url: "https://example.com", label: "Example", colorHex: nil)
        )
        XCTAssertEqual(
            SessionLocalCommands.parse("link <https://example.com> \"Example\" #FF0000"),
            .link(url: "https://example.com", label: "Example", colorHex: "FF0000")
        )
    }

    func testUnknownCommandPreservesBody() {
        XCTAssertEqual(
            SessionLocalCommands.parse("set status sidebar nope"),
            .unknown(body: "set status sidebar nope")
        )
    }
}
