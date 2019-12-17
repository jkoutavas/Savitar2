//
//  WorldTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/15/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class WorldTests: XCTestCase {

    func testv1WorldXMLtoV2() throws {
        // v1 XML
        let xmlInString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi"
            CMDMARKER="##"
            VARMARKER="%%"
            WILDMARKER="$$"
            FORECOLOR="#FFFFFF"
            BACKCOLOR="#666699"
            LINKCOLOR="#9CA6FF"
            ECHOBGCOLOR="#FFF88F"
            INTENSECOLOR="#FFFFFF"
            INTENSETYPE="0"
            FONT="Monaco"
            FONTSIZE="9"
            MONO="Monaco"
            MONOSIZE="9"
            MCPFONT="Monaco"
            MCPFONTSIZE="9"
            RESOLUTION="80x24x2"
            POSITION="50,50"
            WINDOWSIZE="0,0"
            ZOOMED="FALSE"
            OUTPUTMAX="102400"
            OUTPUTMIN="25600"
            FLUSHTICKS="30"
            RETRYSECS="0"
            KEEPALIVEMINS="0"
        />
        """

        let xml = try XML.parse(xmlInString)
        let w1 = World()
        try w1.parse(xml: xml["WORLD"])

        w1.GUID = "test"
        let xmlOutString = try w1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        // swiftlint:disable line_length
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <WORLD VERSION="2" GUID="test" URL="telnet://dentinmud.org:3000" NAME="Alter Aeon" FLAGS="ansi+html" CMDMARKER="##" VARMARKER="%%" WILDMARKER="$$" FORECOLOR="#FFFFFF" BACKCOLOR="#666699" LINKCOLOR="#9CA6FF" ECHOBGCOLOR="#FFF88F" INTENSECOLOR="#FFFFFF" FONT="Monaco" FONTSIZE="9" MONO="Monaco" MONOSIZE="9" MCPFONT="Monaco" MCPFONTSIZE="9" RESOLUTION="80x24x2" POSITION="50,50" WINDOWSIZE="0,0" ZOOMED="FALSE" OUTPUTMAX="102400" OUTPUTMIN="25600" FLUSHTICKS="30" RETRYSECS="0" KEEPALIVEMINS="0"></WORLD>
        """
        // swiftlint:enable line_length

        XCTAssertEqual(xmlOutString, expectedOutput)
    }
}
