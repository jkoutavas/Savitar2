//
//  Trigger.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/8/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import XCTest
import SwiftyXMLParser

@testable import Savitar2

class TriggerTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGag() {
        var t = Trigger(name: "hide", flags: [.caseSensitive, .exact, .gag])
        XCTAssertEqual(t.reactionTo(line: "Let me hide"),
                                          "Let me ")
        XCTAssertEqual(t.reactionTo(line: "Let me Hide"),
                                          "Let me Hide")

        t.flags = [.exact, .gag]
        XCTAssertEqual(t.reactionTo(line: "Let me hide"),
                                          "Let me ")
        XCTAssertEqual(t.reactionTo(line: "Let me Hide and hide some more"),
                                          "Let me  and  some more")

        t.flags = [.wholeLine, .gag]
        XCTAssertEqual(t.reactionTo(line: "Let me hide"),
                                          "")

        t = Trigger(name: "hid\\w*", flags: [.caseSensitive, .useRegex, .exact, .gag])
        XCTAssertEqual(t.reactionTo(line: "Let hiding happen"),
                                          "Let  happen")
        XCTAssertEqual(t.reactionTo(line: "Let Hiding happen"),
                                          "Let Hiding happen")

        t.flags = [.useRegex, .gag]
        XCTAssertEqual(t.reactionTo(line: "Let hiding happen"),
                                          "Let  happen")
        XCTAssertEqual(t.reactionTo(line: "Let HIDING happen"),
                                          "Let  happen")

        t = Trigger(name: "hid", flags: [.toEndOfWord, .gag])
        XCTAssertEqual(t.reactionTo(line: "Let me Hide and hide some more"),
                                          "Let me  and  some more")

        t = Trigger(name: "hide", flags: .gag, wordEnding: " ")
        XCTAssertEqual(t.reactionTo(line: "Let me Hide and hide some more"),
                                          "Let me and some more")

        t = Trigger(name: "hide", flags: .gag, wordEnding: " \\n")
        // TODO: in order to detect end of line, input line must end with \n
        XCTAssertEqual(t.reactionTo(line: "Let me Hide and hide some more end hide\n"),
                                          "Let me and some more end ")
    }

    func testSubst() {
        let t = Trigger(name: "{company}", flags: [.caseSensitive, .exact, .useSubstitution], substitution: "HEYNOW")
        XCTAssertEqual(t.reactionTo(line: "{company} is cool"),
                                          "HEYNOW is cool")
        XCTAssertEqual(t.reactionTo(line: "{COMPANY} is cool, {CoMpAnY}"),
                                          "{COMPANY} is cool, {CoMpAnY}")

        t.flags = [.exact, .useSubstitution]
        XCTAssertEqual(t.reactionTo(line: "{company} is cool"),
                                          "HEYNOW is cool")
        XCTAssertEqual(t.reactionTo(line: "{COMPANY} is cool, {CoMpAnY}"),
                                          "HEYNOW is cool, HEYNOW")
    }

    func testTextStyleFaces() {
        let esc = "\u{1B}"
        var t = Trigger(name: "bold",
                        style: TrigTextStyle(face: .bold))
        XCTAssertEqual(t.reactionTo(line: "a bold statement"),
                                          "a \(esc)[;1mbold\(esc)[;21m statement")

        t = Trigger(name: "underline", flags: .toEndOfWord,
                    style: TrigTextStyle(face: .underline))
        XCTAssertEqual(t.reactionTo(line: "an underlined word"),
                                          "an \(esc)[;4munderlined\(esc)[;23m word")

        t = Trigger(name: "combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold]))
        XCTAssertEqual(t.reactionTo(line: "a combo match"),
                                          "a \(esc)[;1;4mcombo\(esc)[;21;23m match")

        t = Trigger(name: "super combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold, .blink, .italic]))
        XCTAssertEqual(t.reactionTo(line: "a super combo match"),
                                          "a \(esc)[;1;3;4;5msuper combo\(esc)[;21;23;23;25m match")
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
                        style: TrigTextStyle(face: .bold, foreColor: NSColor.red))
        XCTAssertEqual(t.reactionTo(line: "a bold statement"),
                                          "a \(esc)[;1;38:2;255;0;0mbold\(esc)[;21;39m statement")

        t = Trigger(name: "underline", flags: .toEndOfWord,
                    style: TrigTextStyle(face: .underline, foreColor: NSColor.green))
        XCTAssertEqual(t.reactionTo(line: "an underlined word"),
                                          "an \(esc)[;4;38:2;0;255;0munderlined\(esc)[;23;39m word")

        t = Trigger(name: "combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold], backColor: NSColor.blue))
        XCTAssertEqual(t.reactionTo(line: "a combo match"),
                                          "a \(esc)[;1;4;48:2;0;0;255mcombo\(esc)[;21;23;49m match")

        t = Trigger(name: "super combo", flags: .exact,
                    style: TrigTextStyle(face: [.underline, .bold, .blink, .italic],
                                         foreColor: NSColor.white,
                                         backColor: NSColor.black))
        XCTAssertEqual(t.reactionTo(line: "a super combo match"),
                                          "a \(esc)[;1;3;4;5;38:2;255;255;255;48:2;0;0;0msuper combo\(esc)[;21;23;23;25;39;49m match")
    }

    func testTextFaceFrom() {
        // TODO: make this exhaustive
        let faces = TrigFace.from(string: "normal+bold")
        XCTAssertEqual(faces.union(.italic).description, "normal+bold+italic")
    }

    func testFlagsFrom() {
        // TODO: make this exhaustive
        let flags = TrigFlags.from(string: "useRegex")
        XCTAssertEqual(flags.union(.exact).description, "exact+useRegex")
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
        try t1.parse(xml: xml["TRIGGER"])

        XCTAssertEqual(t1.name, "russ")
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.flags, [.wholeLine, .startsWith])
        XCTAssertEqual(t1.style!.foreColor, NSColor(hex: "#26C9EE"))
        XCTAssertEqual(t1.audioCue, .speakEvent)
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
        try t1.parse(xml: xml["TRIGGER"])

        XCTAssertEqual(t1.name, "^kira")
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.flags, [.wholeLine, .useRegex])
        XCTAssertEqual(t1.style!.foreColor, NSColor(hex: "#EE42BB"))
        XCTAssertEqual(t1.style!.backColor, NSColor(hex: "#000000"))
        XCTAssertEqual(t1.audioCue, .speakEvent)
        XCTAssertEqual(t1.sound, "Click")
        XCTAssertEqual(t1.voice, "Princess")
        XCTAssertEqual(t1.wordEnding, "&-\"")
        XCTAssertEqual(t1.say, "Select a voice from the menu to hear this.")
        XCTAssertEqual(t1.substitution, "heynow!")
    }

    func testXMLParseMinimalV2Trigger() throws {
        let xmlString = """
        <TRIGGER
        </TRIGGER>
        """

        let xml = try XML.parse(xmlString)
        let t1 = Trigger()
        try t1.parse(xml: xml["TRIGGER"])

        XCTAssertEqual(t1.name, "<new trigger>")
        XCTAssertEqual(t1.type, .output)
        XCTAssertEqual(t1.flags, .exact)
        XCTAssertEqual(t1.audioCue, .silent)
    }

}
