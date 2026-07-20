//
//  SessionConnectRetryTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class SessionConnectRetryTests: XCTestCase {
    func testZeroDisablesAutoRetry() {
        XCTAssertFalse(SessionConnectRetry.shouldAutoRetry(retrySecs: 0))
        XCTAssertEqual(SessionConnectRetry.delaySeconds(retrySecs: 0), 0)
    }

    func testPositiveEnablesAutoRetry() {
        XCTAssertTrue(SessionConnectRetry.shouldAutoRetry(retrySecs: 1))
        XCTAssertTrue(SessionConnectRetry.shouldAutoRetry(retrySecs: 30))
        XCTAssertEqual(SessionConnectRetry.delaySeconds(retrySecs: 5), 5)
    }

    func testNegativeTreatedAsDisabled() {
        XCTAssertFalse(SessionConnectRetry.shouldAutoRetry(retrySecs: -1))
        XCTAssertEqual(SessionConnectRetry.delaySeconds(retrySecs: -3), 0)
    }
}
