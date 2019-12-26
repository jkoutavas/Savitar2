//
//  TriggerManTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/14/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class TriggerManTests: XCTestCase {

    func testParseV1Triggers() throws {
        // These are the triggers lifted directly from Jay's "The Camp" v1 world document
        let xmlString = """
        <!DOCTYPE doc [
            <!ENTITY ret "&#38;#13;">
            <!ENTITY cmdmark "&#35;&#35;">
            <!ENTITY varmark "&#37;&#37;">
            <!ENTITY wildmark "&#36;&#36;">
        ]>
        <TRIGGERS>
            <TRIGGER
                NAME="&wildmark;d &wildmark;h:&wildmark;m:&wildmark;s 2000 CDT&ret;"
                TYPE="output"
                FLAGS="matchExactly+disabled+useForeColor+gagged+matchAtStart+caseSensitive"
                FACE="bold"
                AUDIO="silent"
                SOUND="ChuToy">
                <REPLY>
                    &cmdmark;set status output &varmark;h:&varmark;m:&varmark;s&ret;
                </REPLY>
            </TRIGGER>
            <TRIGGER
                NAME="^kira"
                TYPE="output"
                FLAGS="matchWholeLine+useRegex"
                COLOR="#EE42BB"
                AUDIO="speakEvent"
                SOUND="Click"
                VOICE="Princess">
                <WORDEND>
                    &amp;-&quot;
                </WORDEND>
                <SAY>
                     Select a voice from the menu to hear this.
                </SAY>
            </TRIGGER>
            <TRIGGER
                NAME="for a total of &wildmark;point points"
                TYPE="output"
                FLAGS="matchExactly+useForeColor"
                AUDIO="speakEvent"
                SOUND="Click"
            />
            <TRIGGER
                NAME="for &wildmark;points points"
                TYPE="output"
                FLAGS="matchExactly+useForeColor"
                AUDIO="speakEvent"
                SOUND="Click"
            />
            <TRIGGER
                NAME="/&wildmark;words"
                TYPE="input"
                FLAGS="matchExactly+disabled+useForeColor+gagged+matchAtStart"
                FACE="bold"
                AUDIO="silent"
                SOUND="ChuToy">
                <REPLY>
                    @ospd &varmark;words
                </REPLY>
            </TRIGGER>
            <TRIGGER
                NAME="-&wildmark;word &wildmark;pos"
                TYPE="input"
                FLAGS="matchExactly+disabled+useForeColor+matchAtStart+notStyled"
                FACE="bold"
                AUDIO="silent"
                SOUND="ChuToy">
                <REPLY>
                    play &varmark;word across &varmark;pos
                </REPLY>
            </TRIGGER>
        </TRIGGERS>
        """

        let xml = try XML.parse(xmlString)
        let tm = TriggerMan()
        try tm.parse(xml: xml)

        XCTAssertEqual(tm.get().count, 6)

        XCTAssertEqual(tm.get()[0].name, "$$d $$h:$$m:$$s 2000 CDT ")
        // TODO: the following tests fails due to an XMLParser bug. See comments in SwiftyXMLParserTests
//        XCTAssertEqual(tm.get()[0].reply, "##set status output %%h:%%m:%%s ")

        XCTAssertEqual(tm.get()[1].name, "^kira")

        XCTAssertEqual(tm.get()[2].name, "for a total of $$point points")

        XCTAssertEqual(tm.get()[3].name, "for $$points points")

        XCTAssertEqual(tm.get()[4].name, "/$$words")

        XCTAssertEqual(tm.get()[5].name, "-$$word $$pos")
    }
}
