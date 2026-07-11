//
//  ClickerManTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import SwiftyXMLParser
import XCTest

@testable import Savitar2

class ClickerManTests: XCTestCase {
    func testFactoryDefaultsMatchSlotOrder() {
        let man = ClickerMan()
        XCTAssertEqual(man.slots.count, 23)
        for (index, slotID) in ClickerSlotID.allCases.enumerated() {
            XCTAssertEqual(man.slots[index].id, slotID)
            XCTAssertEqual(man.slots[index].macroName, slotID.defaultMacroName)
        }
        XCTAssertEqual(ClickerSlotID.ten.whimsicalLabel, "a")
        XCTAssertEqual(ClickerSlotID.ten.defaultMacroName, "MACRO_A")
        XCTAssertEqual(ClickerSlotID.fifteen.whimsicalLabel, "f")
        XCTAssertEqual(ClickerSlotID.fifteen.defaultMacroName, "MACRO_F")
    }

    func testParseLegacyHyphenatedLetterBindings() throws {
        let xml = """
        <PREFERENCES>
            <ALIASES>
                <ALIAS NAME="MACRO-A"/>
            </ALIASES>
        </PREFERENCES>
        """
        let parsed = try XML.parse(xml)
        let man = ClickerMan()
        try man.parse(xml: parsed["PREFERENCES"])

        XCTAssertEqual(man.slot(for: .ten).macroName, "MACRO_A")
    }

    func testParseV1StyleAliases() throws {
        let xml = """
        <PREFERENCES>
            <ALIASES>
                <ALIAS NAME="MACRO_NORTH"/>
                <ALIAS NAME="MACRO_NEAST"/>
                <ALIAS NAME="MACRO_EAST"/>
                <ALIAS NAME="MACRO_SEAST"/>
                <ALIAS NAME="MACRO_SOUTH"/>
                <ALIAS NAME="MACRO_SWEST"/>
                <ALIAS NAME="MACRO_WEST"/>
                <ALIAS NAME="MACRO_NWEST"/>
                <ALIAS NAME="CUSTOM_1"/>
                <ALIAS NAME="CUSTOM_2"/>
            </ALIASES>
        </PREFERENCES>
        """
        let parsed = try XML.parse(xml)
        let man = ClickerMan()
        try man.parse(xml: parsed["PREFERENCES"])

        XCTAssertEqual(man.slot(for: .north).macroName, "MACRO_NORTH")
        XCTAssertEqual(man.slot(for: .one).macroName, "CUSTOM_1")
        XCTAssertEqual(man.slot(for: .two).macroName, "CUSTOM_2")
        XCTAssertEqual(man.slot(for: .three).macroName, "MACRO_3")
        XCTAssertEqual(man.slot(for: .eleven).macroName, "MACRO_B")
    }

    func testParseV1EighteenAliasImportPreservesMacro10OnA() throws {
        let xml = """
        <PREFERENCES>
            <ALIASES>
                <ALIAS NAME="MACRO_NORTH"/>
                <ALIAS NAME="MACRO_NEAST"/>
                <ALIAS NAME="MACRO_EAST"/>
                <ALIAS NAME="MACRO_SEAST"/>
                <ALIAS NAME="MACRO_SOUTH"/>
                <ALIAS NAME="MACRO_SWEST"/>
                <ALIAS NAME="MACRO_WEST"/>
                <ALIAS NAME="MACRO_NWEST"/>
                <ALIAS NAME="MACRO_1"/>
                <ALIAS NAME="MACRO_2"/>
                <ALIAS NAME="MACRO_3"/>
                <ALIAS NAME="MACRO_4"/>
                <ALIAS NAME="MACRO_5"/>
                <ALIAS NAME="MACRO_6"/>
                <ALIAS NAME="MACRO_7"/>
                <ALIAS NAME="MACRO_8"/>
                <ALIAS NAME="MACRO_9"/>
                <ALIAS NAME="MACRO_10"/>
            </ALIASES>
        </PREFERENCES>
        """
        let parsed = try XML.parse(xml)
        let man = ClickerMan()
        try man.parse(xml: parsed["PREFERENCES"])

        XCTAssertEqual(man.slot(for: .ten).macroName, "MACRO_10")
        XCTAssertEqual(man.slot(for: .eleven).macroName, "MACRO_B")
        XCTAssertEqual(man.slot(for: .fifteen).macroName, "MACRO_F")
    }

    func testRoundTripSerialization() throws {
        let man = ClickerMan()
        man.setMacroName("LOOK", for: .one)
        man.setMacroName("", for: .ten)

        let elem = try man.toXMLElement()
        let xml = """
        <PREFERENCES>\(elem.xmlString)</PREFERENCES>
        """
        let parsed = try XML.parse(xml)
        let loaded = ClickerMan()
        try loaded.parse(xml: parsed["PREFERENCES"])

        XCTAssertEqual(loaded.slot(for: .one).macroName, "LOOK")
        XCTAssertEqual(loaded.slot(for: .ten).macroName, "")
        XCTAssertEqual(loaded.slots.count, 23)
    }
}
