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

    func testParseExistingCommands() {
        XCTAssertEqual(SessionLocalCommands.parse("dump"), .dump)
        XCTAssertEqual(SessionLocalCommands.parse("history"), .history)
    }

    func testUnknownCommandPreservesBody() {
        XCTAssertEqual(
            SessionLocalCommands.parse("set status sidebar nope"),
            .unknown(body: "set status sidebar nope")
        )
    }
}
