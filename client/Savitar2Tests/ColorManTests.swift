//
//  ColorManTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser
import XCTest

@testable import Savitar2

class ColorManTests: XCTestCase {
    func testColors() throws {
        // These are the colors lifted directly from StarupPreferences.xml
        let xmlString = """
        <COLORS>
            <COLOR
                NAME="black"
                RGB="#000000"
            />
            <COLOR
                NAME="blackd"
                RGB="#616161"
            />
            <COLOR
                NAME="blacki"
                RGB="#000000"
            />
            <COLOR
                NAME="red"
                RGB="#B00707"
            />
            <COLOR
                NAME="redd"
                RGB="#AC0707"
            />
            <COLOR
                NAME="redi"
                RGB="#DC0707"
            />
            <COLOR
                NAME="green"
                RGB="#00A51D"
            />
            <COLOR
                NAME="greend"
                RGB="#008E2F"
            />
            <COLOR
                NAME="greeni"
                RGB="#23D916"
            />
            <COLOR
                NAME="yellow"
                RGB="#E6B319"
            />
            <COLOR
                NAME="yellowd"
                RGB="#D6A309"
            />
            <COLOR
                NAME="yellowi"
                RGB="#FAF305"
            />
            <COLOR
                NAME="blue"
                RGB="#4D00B4"
            />
            <COLOR
                NAME="blued"
                RGB="#00009F"
            />
            <COLOR
                NAME="bluei"
                RGB="#0000FA"
            />
            <COLOR
                NAME="magenta"
                RGB="#B000A1"
            />
            <COLOR
                NAME="magentad"
                RGB="#A00090"
            />
            <COLOR
                NAME="magentai"
                RGB="#F30785"
            />
            <COLOR
                NAME="cyan"
                RGB="#00B0B0"
            />
            <COLOR
                NAME="cyand"
                RGB="#0090A0"
            />
            <COLOR
                NAME="cyani"
                RGB="#02ABEB"
            />
            <COLOR
                NAME="white"
                RGB="#FFFFFF"
            />
            <COLOR
                NAME="whited"
                RGB="#BFBFBF"
            />
            <COLOR
                NAME="whitei"
                RGB="#FFFFFF"
            />
        </COLORS>
        """

        let xml = try XML.parse(xmlString)
        let cm = ColorMan()
        try cm.parse(xml: xml)

        XCTAssertEqual(cm.get().count, 24)

        XCTAssertEqual(cm.get()[23].name, "whitei")

        XCTAssertEqual(cm.get()[23].color, NSColor(hex: "#FFFFFF"))
    }
}
