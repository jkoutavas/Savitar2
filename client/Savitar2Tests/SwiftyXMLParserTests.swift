//
//  SwiftyXMLParserTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/14/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class SwiftyXMLParserTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testCustomEntities() throws {
        let xmlString = """
        <!DOCTYPE doc [
            <!ENTITY ret "&#38;#13;">
            <!ENTITY cmdmark "&#35;&#35;">
            <!ENTITY varmark "&#37;&#37;">
            <!ENTITY wildmark "&#36;&#36;">
        ]>
        <DOCUMENT title="Doc Title&wildmark;">
            <test1>
                &quot;heynow&quot;
            </test1>
            <test2 text="&varmark;content">
                &cmdmark;foo
            </test2>
        </DOCUMENT>
        """

        let xml = try XML.parse(xmlString)

        XCTAssertEqual(xml["DOCUMENT"].attributes["title"], "Doc Title$$")

        if let test = xml["DOCUMENT"]["test1"].text {
            XCTAssertEqual(test.trimmingCharacters(in: .whitespacesAndNewlines), "\"heynow\"")
        }

        XCTAssertEqual(xml["DOCUMENT"]["test2"].attributes["text"], "%%content")

/*
        // TODO: this test fails when dealing with defined entities. It's a known issue with Apple's XMLParser
        // https://stackoverflow.com/questions/44680734/parsing-xml-with-entities-in-swift-with-xmlparser?noredirect=1&lq=1
        // and I should move over to using another parser, one that's libxml2 based, like FoundationXMKL
        // https://forums.swift.org/t/new-swift-corelibs-foundation-module-foundationxml/27544
        if let text = xml["DOCUMENT"]["test2"].text {
            XCTAssertEqual(text.trimmingCharacters(in: .whitespacesAndNewlines), "##foo")
        }
*/
    }
}
