//
//  WorldTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/15/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser
import XCTest

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
        try w1.parse(xml: xml[WorldElemIdentifier])

        let xmlOutString = try w1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        // swiftlint:disable line_length
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <WORLD URL="telnet://dentinmud.org:3000" NAME="Alter Aeon" FLAGS="ansi+html" CMDMARKER="##" VARMARKER="%%" WILDMARKER="$$" FORECOLOR="#FFFFFF" BACKCOLOR="#666699" LINKCOLOR="#9CA6FF" ECHOBGCOLOR="#FFF88F" INTENSECOLOR="#FFFFFF" FONT="Monaco" FONTSIZE="9" MONO="Monaco" MONOSIZE="9" MCPFONT="Monaco" MCPFONTSIZE="9" RESOLUTION="80x24x2" POSITION="50,50" WINDOWSIZE="0,0" ZOOMED="FALSE" OUTPUTMAX="102400" OUTPUTMIN="25600" FLUSHTICKS="30" RETRYSECS="0" KEEPALIVEMINS="0"></WORLD>
        """
        // swiftlint:enable line_length

        XCTAssertEqual(xmlOutString, expectedOutput)

        XCTAssertEqual(w1.triggerMan.get().count, 0)

        XCTAssertEqual(w1.macroMan.get().count, 0)
    }

    func testv1WorldXMLWithTriggersToV2() throws {
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
            KEEPALIVEMINS="0">
            <LOGONCMD>connect spinlock fnordy\nwho</LOGONCMD>
            <LOGOFFCMD>@quit</LOGOFFCMD>
            <TRIGGERS>
                <TRIGGER
                    NAME="^joan"
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
            </TRIGGERS>
        </WORLD>
        """

        let xml = try XML.parse(xmlInString)
        let w1 = World()
        try w1.parse(xml: xml[WorldElemIdentifier])

        let xmlOutString = try w1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        // swiftlint:disable line_length
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <WORLD URL="telnet://dentinmud.org:3000" NAME="Alter Aeon" FLAGS="ansi+html" CMDMARKER="##" VARMARKER="%%" WILDMARKER="$$" FORECOLOR="#FFFFFF" BACKCOLOR="#666699" LINKCOLOR="#9CA6FF" ECHOBGCOLOR="#FFF88F" INTENSECOLOR="#FFFFFF" FONT="Monaco" FONTSIZE="9" MONO="Monaco" MONOSIZE="9" MCPFONT="Monaco" MCPFONTSIZE="9" RESOLUTION="80x24x2" POSITION="50,50" WINDOWSIZE="0,0" ZOOMED="FALSE" OUTPUTMAX="102400" OUTPUTMIN="25600" FLUSHTICKS="30" RETRYSECS="0" KEEPALIVEMINS="0">
            <LOGONCMD>connect spinlock fnordy\nwho</LOGONCMD>
            <LOGOFFCMD>@quit</LOGOFFCMD>
            <TRIGGERS>
                <TRIGGER NAME="^joan" TYPE="output" FLAGS="matchWholeLine+useRegex" FACE="foreColor" FGCOLOR="#EE42BB" SOUND="Click" AUDIO="speakEvent" VOICE="Princess">
                    <WORDEND>&amp;-"</WORDEND>
                    <SAY>Select a voice from the menu to hear this.</SAY>
                </TRIGGER>
            </TRIGGERS>
        </WORLD>
        """
        // swiftlint:enable line_length

        XCTAssertEqual(xmlOutString, expectedOutput)
    }
}

private class MockSessionHandler: SessionHandlerProtocol {
    var outputs: [String] = []
    var errors: [String] = []
    var printedSource = false
    var history: [String] = []

    func connectionStatusChanged(status _: ConnectionStatus) {}

    func output(result: OutputResult) {
        switch result {
        case let .success(output):
            outputs.append(output)
        case let .error(error):
            errors.append(error)
        }
    }

    func printSource() {
        printedSource = true
    }

    func commandHistory() -> [String] {
        return history
    }
}

class SessionLocalCommandTests: XCTestCase {
    func testHistoryCommandPrintsCommandHistory() {
        let world = World()
        let handler = MockSessionHandler()
        handler.history = ["look", "say hello", "##history"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##history"))

        XCTAssertEqual(handler.outputs, [
            "[SAVITAR] Command history:\n1  look\n2  say hello\n3  ##history\n"
        ])
        XCTAssertTrue(handler.errors.isEmpty)
        XCTAssertFalse(handler.printedSource)
    }

    func testHistoryCommandUsesWorldCommandMarker() {
        let world = World()
        world.cmdMarker = "//"
        let handler = MockSessionHandler()
        handler.history = ["//history"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "//history"))

        XCTAssertEqual(handler.outputs, ["[SAVITAR] Command history:\n1  //history\n"])
    }

    func testDumpCommandUsesLocalCommandDispatcher() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##dump"))

        XCTAssertTrue(handler.printedSource)
        XCTAssertTrue(handler.outputs.isEmpty)
    }
}
