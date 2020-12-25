//
//  MacroManTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser
import XCTest

@testable import Savitar2

class VariableManTests: XCTestCase {
    func testMacros() throws {
        // These are the macros lifted directly from StarupPreferences.xml
        // swiftlint:disable line_length
        let xmlString = """
        <!DOCTYPE doc [
            <!ENTITY ret "&#38;#13;">
        ]>
        <VARIABLES>
            <MACRO
                NAME="MACRO_NORTH"
                KEY="KP8">
                <VALUE>
                    north
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_NEAST"
                KEY="KP9">
                <VALUE>
                    ne
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_EAST"
                KEY="KP6">
                <VALUE>
                    east
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_SEAST"
                KEY="KP3">
                <VALUE>
                    se
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_SOUTH"
                KEY="KP2">
                <VALUE>
                    south
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_SWEST"
                KEY="KP1">
                <VALUE>
                    sw
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_WEST"
                KEY="KP4">
                <VALUE>
                    west
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_NWEST"
                KEY="KP7">
                <VALUE>
                    nw
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_UP"
                KEY="KP+">
                <VALUE>
                    up
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_DOWN"
                KEY="KP-">
                <VALUE>
                    down
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_1"
                KEY="F1">
                <VALUE>
                    look
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_2"
                KEY="F2">
                <VALUE>
                    home
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_3"
                KEY="F3">
                <VALUE>
                    who
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_4"
                KEY="F4">
                <VALUE>
                    say Now here&apos;s a long and drawn out sentence that I generated using that macro &apos;Clicker&apos; thingy found in Savitar. Woo Woo!
                </VALUE>
            </MACRO>
            <MACRO
                NAME="MACRO_5"
                KEY="F5">
                <VALUE>
                    say Here is command one...&ret;say ...and here is command two!
                </VALUE>
            </MACRO>
        </VARIABLES>
        """

        let xml = try XML.parse(xmlString)
        let mm = MacroMan()
        try mm.parse(xml: xml)

        XCTAssertEqual(mm.get().count, 15)

        XCTAssertEqual(mm.get()[12].name, "MACRO_3")

        XCTAssertEqual(mm.get()[12].value, "who")

        XCTAssertEqual(mm.get()[12].keyLabel, "F3")
    }
}
