//
//  VariableTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class VariableTests: XCTestCase {

    func testV1RetEntity() throws {
        // v1 Savitar variables use the "&ret;" custom entity to separate lines of text.
        // XMLParser has a known bug with handling custom entities (of which SwiftyXMLParser is based)
        // See: https://stackoverflow.com/questions/44680734/parsing-xml-with-entities-in-swift-with-xmlparser
        // This test is here to sig nal if/when this gets sorted out. Like, if/when there's a move to
        // libxml2, for example.
        let xmlString = """
        <!DOCTYPE doc [
            <!ENTITY ret "&#38;#13;">
        ]>
        <MACRO
            NAME="MACRO_5"
            KEY="F5">
            <VALUE>
                say Here is command one...&ret;say ...and here is command two!
            </VALUE>
        </MACRO>
        """

        let xml = try XML.parse(xmlString)
        let v1 = Variable()
        try v1.parse(xml: xml[VariableElemIdentifier])

        XCTAssertEqual(v1.name, "MACRO_5")

        XCTAssertEqual(v1.value, "say Here is command one...say ...and here is command two!"
        )

        XCTAssertEqual(v1.keySequence, "F5")
    }

    func testV2CarriageReturn() throws {
        // Here we're simply inlining a &#13; entity to indicate a line feed. (Where as v1 Savitar macros
        // would use a "&ret;" custom entity
        let xmlString = """
        <MACRO
            NAME="MACRO_5"
            KEY="F5">
            <VALUE>
                say Here is command one...&#13;say ...and here is command two!
            </VALUE>
        </MACRO>
        """

        let xml = try XML.parse(xmlString)
        let v1 = Variable()
        try v1.parse(xml: xml[VariableElemIdentifier])

        XCTAssertEqual(v1.name, "MACRO_5")

        XCTAssertEqual(v1.value, "say Here is command one...\rsay ...and here is command two!")

        XCTAssertEqual(v1.keySequence, "F5")
    }
}
