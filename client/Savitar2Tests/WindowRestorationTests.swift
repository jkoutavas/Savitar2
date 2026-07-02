//
//  WindowRestorationTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

import SwiftyXMLParser

class WindowRestorationTests: XCTestCase {
    func testOpenSessionsXMLRoundTrip() throws {
        let worldID = SavitarObjectID()
        let sessions: [SavedOpenSession] = [
            .file(URL(fileURLWithPath: "/tmp/example.world")),
            .pickerWorld(worldID),
            .worldPickerWindow,
            .eventsWindow
        ]

        guard let openSessionsElem = WindowRestoration.openSessionsElement(for: sessions) else {
            XCTFail("Expected open sessions element")
            return
        }

        let xml = XML.parse(openSessionsElem.xmlString)
        let parsed = WindowRestoration.parseOpenSessions(xml: xml)

        XCTAssertEqual(parsed.count, 4)
        XCTAssertEqual(parsed[0], .file(URL(fileURLWithPath: "/tmp/example.world")))
        XCTAssertEqual(parsed[1], .pickerWorld(worldID))
        XCTAssertEqual(parsed[2], .worldPickerWindow)
        XCTAssertEqual(parsed[3], .eventsWindow)
    }

    func testParseOpenSessionsMissingElement() {
        let xml = XML.parse("<PREFERENCES></PREFERENCES>")
        XCTAssertTrue(WindowRestoration.parseOpenSessions(xml: xml).isEmpty)
    }

    func testOpenSessionsElementEmpty() {
        XCTAssertNil(WindowRestoration.openSessionsElement(for: []))
    }
}
