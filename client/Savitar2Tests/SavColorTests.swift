//
//  SavColorTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class SavColorTests: XCTestCase {

     func testV2CarriageReturn() throws {
        let xmlString = """
        <COLOR
            NAME="red"
            RGB="#B00707"
        />
        """

        let xml = try XML.parse(xmlString)
        let c1 = SavColor()
        try c1.parse(xml: xml[ColorElemIdentifier])

        XCTAssertEqual(c1.name, "red")

        XCTAssertEqual(c1.color, NSColor.init(hex: "#B00707"))
    }
}
