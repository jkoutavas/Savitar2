//
//  OutputEchoBackTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class OutputEchoBackTests: XCTestCase {
    func testEchoBackHTMLWrapsAndEscapes() {
        let html = OutputView.echoBackHTML(from: "look\n<tag>")
        XCTAssertEqual(html, "<span class=\"savitar-echo-back\">look<br>&lt;tag&gt;</span>")
    }

    func testEchoBackHTMLEmptyInputReturnsEmptyString() {
        XCTAssertEqual(OutputView.echoBackHTML(from: ""), "")
    }

    func testEchoBackHTMLWithQuotedSoundNameEscapesForJavaScript() {
        let html = OutputView.echoBackHTML(from: "[SAVITAR] Unknown sound \"Bogus\".\n")
        XCTAssertTrue(html.contains("class=\"savitar-echo-back\""))
        XCTAssertTrue(html.contains("Unknown sound \"Bogus\"."))
    }

    func testWorldEchoBackColorDefaultsToV1Yellow() {
        let world = World()
        XCTAssertEqual(world.echoBackColor.toHex, "FFF88F")
    }

    func testReadableTextColorOnEchoBackYellowIsBlack() {
        let echoBack = NSColor(hex: "#FFF88F")!
        XCTAssertEqual(echoBack.readableTextColor().toHex, "000000")
    }

    func testReadableTextColorOnDarkBackgroundIsWhite() {
        let dark = NSColor(hex: "#666699")!
        XCTAssertEqual(dark.readableTextColor().toHex, "FFFFFF")
    }
}
