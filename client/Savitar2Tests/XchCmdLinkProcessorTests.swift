//
//  XchCmdLinkProcessorTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class XchCmdLinkProcessorTests: XCTestCase {
    func testProcessAddsHrefForXchCmd() {
        let input = #"<a xch_cmd="look">Look around</a>"#
        let output = XchCmdLinkProcessor.process(input)
        XCTAssertTrue(output.contains("href=\"savitar-xch:/look\""))
        XCTAssertTrue(output.contains("xch_cmd=\"look\""))
    }

    func testProcessAddsTitleFromXchHint() {
        let input = #"<a xch_cmd="who" xch_hint="Who is online?">Who</a>"#
        let output = XchCmdLinkProcessor.process(input)
        XCTAssertTrue(output.contains("title=\"Who is online?\""))
    }

    func testCommandRoundTrip() {
        let command = "look north"
        guard let href = XchCmdLinkProcessor.hrefURL(for: command),
              let url = URL(string: href),
              let decoded = XchCmdLinkProcessor.command(from: url) else {
            return XCTFail("Expected savitar-xch URL")
        }
        XCTAssertEqual(decoded, command)
    }

    func testPassthroughWithoutXchCmd() {
        let input = #"<a href="https://example.com">Example</a>"#
        XCTAssertEqual(XchCmdLinkProcessor.process(input), input)
    }
}
