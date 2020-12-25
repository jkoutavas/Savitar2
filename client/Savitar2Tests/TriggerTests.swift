//
//  Trigger.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/8/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser
import XCTest

@testable import Savitar2

class TriggerTests: XCTestCase {
    override func setUp() {}

    override func tearDown() {}

    func testGag() {
        var t = Trigger(name: "hide", flags: [.caseSensitive, .exact, .gag])
        var line = "let me hide"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "let me ")
        line = "Let me Hide"
        XCTAssertFalse(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me Hide")

        t.flags = [.exact, .gag]
        line = "Let me hide"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me ")
        line = "Let me Hide and hide some more"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me  and  some more")

        t.flags = [.wholeLine, .gag]
        line = "Let me hide"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "")

        t = Trigger(name: "hid\\w*", flags: [.caseSensitive, .useRegex, .exact, .gag])
        line = "Let hiding happen"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let  happen")
        line = "Let Hiding happen"
        XCTAssertFalse(t.reactionTo(line: &line))

        t.flags = [.useRegex, .gag]
        line = "Let hiding happen"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let  happen")
        line = "Let HIDING happen"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let  happen")

        t = Trigger(name: "hid", flags: [.toEndOfWord, .gag])
        line = "Let me Hide and hide some more"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me  and  some more")

        t = Trigger(name: "hide", flags: .gag, wordEnding: " ")
        line = "Let me Hide and hide some more"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me and some more")

        t = Trigger(name: "hide", flags: .gag, wordEnding: " \\n")
        // TODO: in order to detect end of line, input line must end with \n
        line = "Let me Hide and hide some more end hide\n"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "Let me and some more end ")
    }

    func testSubst() {
        let t = Trigger(name: "{company}", flags: [.caseSensitive, .exact, .useSubstitution], substitution: "HEYNOW")
        var line = "{company} is cool"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "HEYNOW is cool")
        line = "{COMPANY} is cool, {CoMpAnY}"
        XCTAssertFalse(t.reactionTo(line: &line))

        t.flags = [.exact, .useSubstitution]
        line = "{company} is cool"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "HEYNOW is cool")
        line = "{COMPANY} is cool, {CoMpAnY}"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "HEYNOW is cool, HEYNOW")
    }

    func testTextStyleFaces() {
        let esc = "\u{1B}"
        var t = Trigger(name: "bold",
                        style: TrigTextStyle(face: .bold))
        var line = "a bold statement"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "a \(esc)[;1mbold\(esc)[;21m statement")

        t = Trigger(name: "underline", flags: .toEndOfWord,
                    style: TrigTextStyle(face: .underline))
        line = "an underlined word"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "an \(esc)[;4munderlined\(esc)[;24m word")

        t = Trigger(name: "combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold]))
        line = "a combo match"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "a \(esc)[;1;4mcombo\(esc)[;21;24m match")

        t = Trigger(name: "super combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold, .blink, .italic]))
        line = "a super combo match"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "a \(esc)[;1;3;4;5msuper combo\(esc)[;21;23;24;25m match")

        t = Trigger(name: "whole", flags: .wholeLine,
                    style: TrigTextStyle(face: .underline))
        line = "This is a whole line match\r"
        XCTAssertTrue(t.reactionTo(line: &line))
        // it's important that the \r ends the line
        XCTAssertEqual(line, "\(esc)[;4mThis is a whole line match\(esc)[;24m\r")
    }

    func testColorExtension() {
        // Regardless of the number of internal components a color makes up, we return 3 values (r,g,b)
        // Black and white are interesting, because internally they're represented with two components
        // (repeated color plus alpha).
        XCTAssertEqual(NSColor.black.toIntArray().count, 3)
        XCTAssertEqual(NSColor.white.toIntArray().count, 3)

        // And you would expect something like purple to return >=3 components
        XCTAssertEqual(NSColor.purple.toIntArray().count, 3)
    }

    func testTextStyleColors() {
        let esc = "\u{1B}"
        var t = Trigger(name: "bold",
                        style: TrigTextStyle(face: [.bold, .foreColor], foreColor: NSColor.red))
        var line = "a bold statement"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "a \(esc)[;1;38:2;255;0;0mbold\(esc)[;21;39m statement")

        t = Trigger(name: "underline", flags: .toEndOfWord,
                    style: TrigTextStyle(face: [.underline, .foreColor], foreColor: NSColor.green))
        line = "an underlined word"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "an \(esc)[;4;38:2;0;255;0munderlined\(esc)[;24;39m word")

        t = Trigger(name: "combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold, .backColor], backColor: NSColor.blue))
        line = "a combo match"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line, "a \(esc)[;1;4;48:2;0;0;255mcombo\(esc)[;21;24;49m match")

        t = Trigger(name: "super combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold, .blink, .italic, .foreColor, .backColor],
                                         foreColor: NSColor.white,
                                         backColor: NSColor.black))
        line = "a super combo match"
        XCTAssertTrue(t.reactionTo(line: &line))
        XCTAssertEqual(line,
                       "a \(esc)[;1;3;4;5;38:2;255;255;255;48:2;0;0;0msuper combo\(esc)[;21;23;24;25;39;49m match")
        // swiftlint:enable line_length
    }

    func testTrigFaceFrom() {
        // TODO: make this exhaustive
        let faces = TrigFace.from(string: "normal+bold")
        XCTAssertEqual(faces.union(.italic).description, "normal+bold+italic")
    }

    func testTrigFlagsFrom() {
        // TODO: make this exhaustive
        let flags = TrigFlags.from(string: "useRegex")
        XCTAssertEqual(flags.union(.exact).description, "matchExactly+useRegex")
    }

    func testXMLParseV1Trigger() throws {
        // note the misspelled <SUBSITUTION> element
        let xmlString = """
        <TRIGGER
            NAME="russ"
            TYPE="output"
            FLAGS="matchWholeLine+matchAtStart"
            COLOR="#26C9EE"
            AUDIO="speakEvent"
            SOUND="Click"
            VOICE="Ralph">
            <WORDEND>
                &amp;-&quot;
            </WORDEND>
            <SAY>
                 Select a voice from the menu to hear this.
            </SAY>
            <SUBSITUTION>
                oh boy, oh boy
            </SUBSITUTION>
        </TRIGGER>
        """

        let xml = try XML.parse(xmlString)
        let t1 = Trigger()
        try t1.parse(xml: xml[TriggerElemIdentifier])

        XCTAssertEqual(t1.name, "russ")
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.flags, [.wholeLine, .startsWith])
        XCTAssertEqual(t1.style!.foreColor, NSColor(hex: "#26C9EE"))
        XCTAssertEqual(t1.audioType, .speakEvent)
        XCTAssertEqual(t1.sound, "Click")
        XCTAssertEqual(t1.voice, "Ralph")
        XCTAssertEqual(t1.wordEnding, "&-\"")
        XCTAssertEqual(t1.say, "Select a voice from the menu to hear this.")
        XCTAssertEqual(t1.substitution, "oh boy, oh boy")
    }

    func testXMLParseV2Trigger() throws {
        // note the correctly spelled <SUBSTITUTION> element
        // note COLOR attribute has been renamed to FGCOLOR
        // note new BGCOLOR attribute
        let xmlString = """
        <TRIGGER
            NAME="^kira"
            TYPE="output"
            FLAGS="matchWholeLine+useRegex"
            FGCOLOR="#EE42BB"
            BGCOLOR="#000000"
            AUDIO="speakEvent"
            SOUND="Click"
            VOICE="Princess">
            <WORDEND>&amp;-&quot;</WORDEND>
            <SAY>Select a voice from the menu to hear this.</SAY>
            <SUBSTITUTION>heynow!</SUBSTITUTION>
        </TRIGGER>
        """

        let xml = try XML.parse(xmlString)
        let t1 = Trigger()
        try t1.parse(xml: xml[TriggerElemIdentifier])

        XCTAssertEqual(t1.name, "^kira")
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.flags, [.wholeLine, .useRegex])
        XCTAssertEqual(t1.style!.foreColor, NSColor(hex: "#EE42BB"))
        XCTAssertEqual(t1.style!.backColor, NSColor(hex: "#000000"))
        XCTAssertEqual(t1.audioType, .speakEvent)
        XCTAssertEqual(t1.sound, "Click")
        XCTAssertEqual(t1.voice, "Princess")
        XCTAssertEqual(t1.wordEnding, "&-\"")
        XCTAssertEqual(t1.say, "Select a voice from the menu to hear this.")
        XCTAssertEqual(t1.substitution, "heynow!")
    }

    func testXMLParseMinimalV2Trigger() throws {
        let xml = try XML.parse("<TRIGGER/>")
        let t1 = Trigger()
        try t1.parse(xml: xml[TriggerElemIdentifier])

        XCTAssertEqual(t1.name, Trigger.defaultName)
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.audioType, .silent)
    }

    func testv1TriggerXMLtoV2() throws {
        // v1 XML
        // note the misspelled <SUBSITUTION> element
        let xmlInString = """
        <TRIGGER
            NAME="russ"
            TYPE="output"
            FLAGS="matchWholeLine+matchAtStart"
            COLOR="#26C9EE"
            AUDIO="speakEvent"
            SOUND="Click"
            VOICE="Ralph">
            <WORDEND>
                &amp;-&quot;
            </WORDEND>
            <SAY>
                Select a voice from the menu to hear this.
            </SAY>
            <SUBSITUTION>
                oh boy, oh boy
            </SUBSITUTION>
        </TRIGGER>
        """

        let xml = try XML.parse(xmlInString)
        let t1 = Trigger()
        try t1.parse(xml: xml[TriggerElemIdentifier])

        let xmlOutString = try t1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        // swiftlint:disable line_length
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <TRIGGER NAME="russ" TYPE="output" FLAGS="matchWholeLine+matchAtStart" FACE="foreColor" FGCOLOR="#26C9EE" SOUND="Click" AUDIO="speakEvent" VOICE="Ralph">
            <WORDEND>&amp;-"</WORDEND>
            <SAY>Select a voice from the menu to hear this.</SAY>
            <SUBSTITUTION>oh boy, oh boy</SUBSTITUTION>
        </TRIGGER>
        """
        // swiftlint:enable line_length

        XCTAssertEqual(xmlOutString, expectedOutput)
    }

    func testv1TriggerUseForFlagXMLtoV2() throws {
        // v1 XML
        // note the misspelled <SUBSITUTION> element
        let xmlInString = """
        <TRIGGER
            NAME="russ"
            TYPE="output"
            FLAGS="matchWholeLine+matchAtStart+useFore"
            COLOR="#26C9EE"
            AUDIO="speakEvent"
            SOUND="Click"
            VOICE="Ralph">
            <WORDEND>
                &amp;-&quot;
            </WORDEND>
            <SAY>
                Select a voice from the menu to hear this.
            </SAY>
            <SUBSITUTION>
                oh boy, oh boy
            </SUBSITUTION>
        </TRIGGER>
        """

        let xml = try XML.parse(xmlInString)
        let t1 = Trigger()
        try t1.parse(xml: xml[TriggerElemIdentifier])

        let xmlOutString = try t1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        // Here we're expecting that "FLAG"="foreColor" does not get generated. That's because there's a "useFore"
        // in the v1 text XML
        // swiftlint:disable line_length
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <TRIGGER NAME="russ" TYPE="output" FLAGS="matchWholeLine+matchAtStart" FGCOLOR="#26C9EE" SOUND="Click" AUDIO="speakEvent" VOICE="Ralph">
            <WORDEND>&amp;-"</WORDEND>
            <SAY>Select a voice from the menu to hear this.</SAY>
            <SUBSTITUTION>oh boy, oh boy</SUBSTITUTION>
        </TRIGGER>
        """
        // swiftlint:enable line_length

        XCTAssertEqual(xmlOutString, expectedOutput)
    }

    func testAppearanceFlags() throws {
        // these flags are a radio group. Only one of them can be raised at a given time

        let trigger = Trigger()

        trigger.appearance = .gag
        XCTAssertTrue(trigger.flags.contains(.gag))
        XCTAssertTrue(!trigger.flags.contains(.dontUseStyle))

        trigger.appearance = .dontUseStyle
        XCTAssertTrue(!trigger.flags.contains(.gag))
        XCTAssertTrue(trigger.flags.contains(.dontUseStyle))

        trigger.appearance = .changeAppearance
        XCTAssertTrue(!trigger.flags.contains(.gag))
        XCTAssertTrue(!trigger.flags.contains(.dontUseStyle))
    }

    func testMatchingFlags() throws {
        // these flags are a radio group. Only one of them can be raised at a given time

        let trigger = Trigger()

        trigger.matching = .exact
        XCTAssertTrue(trigger.flags.contains(.exact))
        XCTAssertTrue(!trigger.flags.contains(.wholeLine))
        XCTAssertTrue(!trigger.flags.contains(.toEndOfWord))

        trigger.matching = .wholeWord
        XCTAssertTrue(!trigger.flags.contains(.exact))
        XCTAssertTrue(!trigger.flags.contains(.wholeLine))
        XCTAssertTrue(trigger.flags.contains(.toEndOfWord))

        trigger.matching = .wholeLine
        XCTAssertTrue(!trigger.flags.contains(.exact))
        XCTAssertTrue(trigger.flags.contains(.wholeLine))
        XCTAssertTrue(!trigger.flags.contains(.toEndOfWord))
    }

    func testSpecifierFlags() throws {
        // these flags are a radio group. Only one of them can be raised at a given time

        let trigger = Trigger()

        trigger.specifier = .startsWith
        XCTAssertTrue(trigger.flags.contains(.startsWith))
        XCTAssertTrue(!trigger.flags.contains(.useRegex))

        trigger.specifier = .lineContains
        XCTAssertTrue(!trigger.flags.contains(.startsWith))
        XCTAssertTrue(!trigger.flags.contains(.useRegex))

        trigger.specifier = .useRegex
        XCTAssertTrue(!trigger.flags.contains(.startsWith))
        XCTAssertTrue(trigger.flags.contains(.useRegex))
    }
}
