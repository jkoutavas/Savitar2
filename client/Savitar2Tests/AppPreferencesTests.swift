//
//  AppPreferencesTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/23/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
@testable import Savitar2

import SwiftyXMLParser

class AppPreferencesTests: XCTestCase {
    let startingPrefs = AppPreferences()
    let defaultPrefs = AppPreferences()
    var xmlInputStr = ""

    override func setUp() {
        if let filepath = Bundle.main.path(forResource: "StartupPreferences", ofType: "xml") {
            do {
                xmlInputStr = try String(contentsOfFile: filepath).trimmingCharacters(in: .whitespacesAndNewlines)
                let xml = try XML.parse(xmlInputStr)
                try startingPrefs.parse(xml: xml[PreferencesElemIdentifier])
            } catch {
                XCTFail("Error thrown")
            }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAttribs() {
        XCTAssertEqual(startingPrefs.version, defaultPrefs.version)
        XCTAssertEqual(startingPrefs.continuousSpeechEnabled, defaultPrefs.continuousSpeechEnabled)
        XCTAssertEqual(startingPrefs.continuousSpeechRate, defaultPrefs.continuousSpeechRate)
        XCTAssertEqual(startingPrefs.flags, defaultPrefs.flags)
        XCTAssertEqual(startingPrefs.lastUpdateSecs, defaultPrefs.lastUpdateSecs)
        XCTAssertEqual(startingPrefs.updatingEnabled, defaultPrefs.updatingEnabled)
    }

    func testWorldMan() {
        XCTAssertEqual(startingPrefs.worldMan.get().count, 11)
    }

    func testTriggerMan() {
        XCTAssertEqual(AppContext.shared.universalReactionsStore.state.triggerList.items.count, 2)
    }

    func testMacroMan() {
        XCTAssertEqual(AppContext.shared.universalReactionsStore.state.macroList.items.count, 15)
    }

    func testColorMan() {
        XCTAssertEqual(startingPrefs.colorMan.get().count, 24)
    }

    func testXMLOutput() throws {
        let xmlOutputStr = try startingPrefs.toXMLElement().xmlString.prettyXMLFormat()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(xmlOutputStr, xmlInputStr)
    }

}
