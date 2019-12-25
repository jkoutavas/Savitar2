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

    func testRetEntity() throws {
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

        XCTAssertEqual(v1.value, "say Here is command one...\rsay ...and here is command two!"
        )

        XCTAssertEqual(v1.keySequence, "F5")
    }
}
