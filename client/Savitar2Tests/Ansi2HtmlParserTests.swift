//
//  Ansi2HtmlParserTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 11/10/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import XCTest
@testable import Savitar2

class Ansi2HtmlParserTests: XCTestCase {

    func escape(_ ansi: String) -> String {
        let esc = "\u{1B}"
        return ansi.replacingOccurrences(of: "^[", with: "\(esc)[")
    }

    func testPlainText() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: "The rain falls mainly on the plain."),
            "The rain falls mainly on the plain.")
    }

    func testBold() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[1mANSI Intense^[0m")),
            "<span class='bold '>ANSI Intense</span>")
    }

    func testBlink() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[5mANSI Blink^[25m")),
            "<span class='blink '>ANSI Blink</span>")
    }

    func testReverse() {
        var it = Ansi2HtmlParser()
         XCTAssertEqual(it.parse(ansi: escape("^[7mANSI Reverse^[27m")),
            "<span class='inverted bg-inverted '>ANSI Reverse</span><span class='reset bg-reset '></span>")
    }

    func testItalicAndUnderline() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[3;4mANSI Italic and ANSI Underline^[0m")),
            "<span class='underline italic '>ANSI Italic and ANSI Underline</span>")
    }

    func testCrossedout() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[9mANSI Crossed-out^[0m")),
            "<span class='crossed-out '>ANSI Crossed-out</span>")
    }

    func testRedForeColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[31mred^[0m")),
            "<span class='red '>red</span>")
    }

    func testGreenForeColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[32mgreen^[0m")),
            "<span class='green '>green</span>")
    }

    func testBlueForeColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[34mblue^[0m")),
            "<span class='blue '>blue</span>")
    }

    func testRedBackColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[41mred^[0m")),
            "<span class='bg-red '>red</span>")
    }

    func testGreenBackColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[42mgreen^[0m")),
            "<span class='bg-green '>green</span>")
    }

    func testBlueBackColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[44mblue^[0m")),
            "<span class='bg-blue '>blue</span>")
    }

    func test24BitForeColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[38;2;20;50;100m24-bit fore color^[0m")),
            "<span class='' style='color:#143264;'>24-bit fore color</span>")
    }

    func test24BitBackColor() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[48;2;100;50;90m24-bit back color^[0m")),
            "<span class='' style='background-color:#64325a;'>24-bit back color</span>")
    }

    func testScrewy() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[2;37;40mOld Reverse^[0;37;40m (SCREWY!)")),
            "<span class='lighter white bg-black '>Old Reverse</span><span class='white bg-black '> (SCREWY!)</span>")
    }

    func testSplit() {
        var it = Ansi2HtmlParser()
        XCTAssertEqual(it.parse(ansi: escape("^[48;2;100;")), "")
        XCTAssertEqual(it.parse(ansi: escape("50;90m24-bit back color^[0m")),
            "<span class='' style='background-color:#64325a;'>24-bit back color</span>")
    }
}
