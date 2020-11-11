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
         XCTAssertEqual(ansiToHtml(ansi: "The rain falls mainly on the plain."),
            "The rain falls mainly on the plain.")
    }

    func testBold() {
         XCTAssertEqual(ansiToHtml(ansi: escape("^[1mANSI Intense^[0m")),
            "<span class='bold '>ANSI Intense</span>")
    }

    func testBlink() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[5mANSI Blink^[25m")),
            "<span class='blink '>ANSI Blink</span>")
    }

    func testReverse() {
         XCTAssertEqual(ansiToHtml(ansi: escape("^[7mANSI Reverse^[27m")),
            "<span class='inverted bg-inverted '>ANSI Reverse</span><span class='reset bg-reset '></span>")
    }

    func testItalicAndUnderline() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[3;4mANSI Italic and ANSI Underline^[0m")),
            "<span class='underline italic '>ANSI Italic and ANSI Underline</span>")
    }

    func testCrossedout() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[9mANSI Crossed-out^[0m")),
            "<span class='crossed-out '>ANSI Crossed-out</span>")
    }

    func testRedForeColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[31mred^[0m")),
            "<span class='red '>red</span>")
    }

    func testGreenForeColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[32mgreen^[0m")),
            "<span class='green '>green</span>")
    }

    func testBlueForeColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[34mblue^[0m")),
            "<span class='blue '>blue</span>")
    }

    func testRedBackColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[41mred^[0m")),
            "<span class='bg-red '>red</span>")
    }

    func testGreenBackColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[42mgreen^[0m")),
            "<span class='bg-green '>green</span>")
    }

    func testBlueBackColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[44mblue^[0m")),
            "<span class='bg-blue '>blue</span>")
    }

    func test24BitForeColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[38;2;20;50;100m24-bit fore color^[0m")),
            "<span class='' style='color:#143264;'>24-bit fore color</span>")
    }

    func test24BitBackColor() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[48;2;100;50;90m24-bit back color^[0m")),
            "<span class='' style='background-color:#64325a;'>24-bit back color</span>")
    }

    func testScrewy() {
        XCTAssertEqual(ansiToHtml(ansi: escape("^[2;37;40mOld Reverse^[0;37;40m (SCREWY!)")),
            "<span class='lighter white bg-black '>Old Reverse</span><span class='white bg-black '> (SCREWY!)</span>")
    }
}
