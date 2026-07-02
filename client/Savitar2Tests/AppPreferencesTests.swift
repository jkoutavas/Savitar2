//
//  AppPreferencesTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/23/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

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
        XCTAssertEqual(AppContext.shared.worldPickerStore.state.worldList.items.count, 11)
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

    func testSetPrefsFlagAction() {
        var state = AppPreferencesState()
        state = SetPrefsFlagAction(flag: .muteBell, enabled: true).apply(oldState: state)
        XCTAssertTrue(state.prefs.flags.contains(.muteBell))
        state = SetPrefsFlagAction(flag: .muteBell, enabled: false).apply(oldState: state)
        XCTAssertFalse(state.prefs.flags.contains(.muteBell))
    }

    func testSetShowEventsWindowAtStartupAction() {
        var state = AppPreferencesState()
        state = SetShowEventsWindowAtStartupAction(true).apply(oldState: state)
        XCTAssertTrue(state.prefs.flags.contains(.startupEventsWindow))
        state = SetShowEventsWindowAtStartupAction(false).apply(oldState: state)
        XCTAssertFalse(state.prefs.flags.contains(.startupEventsWindow))
    }

    func testSetUpdatingEnabledAction() {
        var state = AppPreferencesState()
        state = SetUpdatingEnabledAction(false).apply(oldState: state)
        XCTAssertFalse(state.prefs.updatingEnabled)
    }

    func testSetContinuousSpeechEnabledAction() {
        var state = AppPreferencesState()
        state = SetContinuousSpeechEnabledAction(true).apply(oldState: state)
        XCTAssertTrue(state.prefs.continuousSpeechEnabled)
        state = SetContinuousSpeechEnabledAction(false).apply(oldState: state)
        XCTAssertFalse(state.prefs.continuousSpeechEnabled)
    }

    func testSpeakerManListsEnglishVoices() {
        let names = AppContext.shared.speakerMan.voiceNames()
        XCTAssertFalse(names.isEmpty, "Expected at least one English system voice")
        XCTAssertFalse(names[0].isEmpty)
    }

    func testResolvedContinuousSpeechVoiceFallsBackToFirstVoice() {
        let names = AppContext.shared.speakerMan.voiceNames()
        XCTAssertFalse(names.isEmpty)
        let resolved = AppContext.shared.speakerMan.resolvedContinuousSpeechVoiceName()
        XCTAssertFalse(resolved.isEmpty)
        XCTAssertTrue(names.contains(resolved))
    }
}
