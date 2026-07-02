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
            .pickerWorld(worldID)
        ]

        guard let openSessionsElem = WindowRestoration.openSessionsElement(for: sessions) else {
            XCTFail("Expected open sessions element")
            return
        }

        let xml = XML.parse(openSessionsElem.xmlString)
        let parsed = WindowRestoration.parseOpenSessions(xml: xml)

        XCTAssertEqual(parsed.count, 2)
        XCTAssertEqual(parsed[0], .file(URL(fileURLWithPath: "/tmp/example.world")))
        XCTAssertEqual(parsed[1], .pickerWorld(worldID))
    }

    func testParseOpenSessionsMissingElement() {
        let xml = XML.parse("<PREFERENCES></PREFERENCES>")
        XCTAssertTrue(WindowRestoration.parseOpenSessions(xml: xml).isEmpty)
    }

    func testOpenSessionsElementEmpty() {
        XCTAssertNil(WindowRestoration.openSessionsElement(for: []))
    }

    func testLegacyAuxiliaryWindowEntriesAreIgnoredOnRestore() {
        let xml = XML.parse("""
        <OPEN_SESSIONS>
            <WINDOW TYPE="worldPicker" />
            <WINDOW TYPE="eventsWindow" />
        </OPEN_SESSIONS>
        """)
        let parsed = WindowRestoration.parseOpenSessions(xml: xml)
        XCTAssertEqual(parsed, [.worldPickerWindow, .eventsWindow])

        WindowRestoration.restoreSavedSessions(parsed, in: AppContext.shared)
        XCTAssertNil(AppContext.shared.worldPickerWindowController)
        XCTAssertNil(AppContext.shared.universalEventsWindowController)
    }

    func testDisableStartupPickerClearsSavedWorldPickerSession() {
        var state = AppPreferencesState()
        state.prefs.openSessions = [.worldPickerWindow, .file(URL(fileURLWithPath: "/tmp/example.world"))]

        let updated = SetShowStartupPickerAction(false).apply(oldState: state)

        XCTAssertFalse(updated.prefs.flags.contains(.startupPicker))
        XCTAssertEqual(updated.prefs.openSessions, [.file(URL(fileURLWithPath: "/tmp/example.world"))])
    }
}
