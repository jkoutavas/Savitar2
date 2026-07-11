//
//  SavitarWelcomeTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class SavitarWelcomeTests: XCTestCase {
    func testWelcomeBannerText() {
        XCTAssertEqual(SavitarWelcome.titleLine, "Welcome to Savitar")
        XCTAssertEqual(
            SavitarWelcome.headerLine(commandMarker: "##"),
            "Welcome to Savitar — type ##help for a list of local commands"
        )
        XCTAssertEqual(
            SavitarWelcome.headerLine(commandMarker: "/"),
            "Welcome to Savitar — type /help for a list of local commands"
        )
        XCTAssertEqual(SavitarWelcome.rightsLine, "All rights reserved.")
        XCTAssertTrue(SavitarWelcome.versionLine.contains("Copyright © 1996-2026, Heynow Software"))
        XCTAssertEqual(SavitarWelcome.websiteURL, "https://www.heynow.com/savitar")
    }

    func testWelcomeHTMLIsSingleTightBlock() {
        let html = SavitarWelcome.html(commandMarker: "##", linkColorHex: "AABBCC")
        XCTAssertTrue(html.contains("<div class=\"savitar-welcome\">"))
        XCTAssertTrue(html.contains("<strong>Welcome to Savitar</strong>"))
        XCTAssertTrue(html.contains("type ##help for a list of local commands"))
        XCTAssertTrue(html.contains("All rights reserved."))
        XCTAssertTrue(html.contains("href=\"https://www.heynow.com/savitar\""))
        XCTAssertTrue(html.contains("color: #AABBCC"))
        XCTAssertTrue(html.contains("\(SavitarWelcome.rightsLine)<br><br></div>"))
    }
}
