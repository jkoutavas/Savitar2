//
//  SessionKeepAliveTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class SessionKeepAliveTests: XCTestCase {
    func testDisabledWhenZeroMinutes() {
        let last = Date(timeIntervalSince1970: 0)
        let now = Date(timeIntervalSince1970: 3600)
        XCTAssertFalse(SessionKeepAlive.shouldSend(keepAliveMins: 0, lastOutbound: last, now: now))
    }

    func testNotDueBeforeInterval() {
        let last = Date(timeIntervalSince1970: 100)
        let now = Date(timeIntervalSince1970: 100 + 60 * 3 - 1)
        XCTAssertFalse(SessionKeepAlive.shouldSend(keepAliveMins: 3, lastOutbound: last, now: now))
    }

    func testDueAtAndAfterInterval() {
        let last = Date(timeIntervalSince1970: 100)
        let atThreshold = Date(timeIntervalSince1970: 100 + 60 * 3)
        let after = Date(timeIntervalSince1970: 100 + 60 * 3 + 30)
        XCTAssertTrue(SessionKeepAlive.shouldSend(keepAliveMins: 3, lastOutbound: last, now: atThreshold))
        XCTAssertTrue(SessionKeepAlive.shouldSend(keepAliveMins: 3, lastOutbound: last, now: after))
    }

    func testNullBytePayload() {
        XCTAssertEqual(SessionKeepAlive.nullBytePayload, Data([0]))
        XCTAssertEqual(SessionKeepAlive.nullBytePayload.count, 1)
    }
}
