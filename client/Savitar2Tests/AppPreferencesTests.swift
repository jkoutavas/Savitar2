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

    override func setUp() {
        if let filepath = Bundle.main.path(forResource: "StartupPreferences", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let xml = try XML.parse(contents)
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
        XCTAssertEqual(startingPrefs.triggerMan.get().count, 2)
    }

    func testVariableMan() {
        XCTAssertEqual(startingPrefs.variableMan.get().count, 15)
    }
}
