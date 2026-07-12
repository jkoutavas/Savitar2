//
//  PaneDimensionsTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import SwiftyXMLParser
import XCTest

class PaneDimensionsTests: XCTestCase {
    func testResolutionParsesColumnsByOutputRowsByInputRows() throws {
        let xmlInString = """
        <WORLD NAME="Test" URL="telnet://example.com:4000" RESOLUTION="80x24x2"/>
        """
        let xml = try XML.parse(xmlInString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertEqual(world.columns, 80)
        XCTAssertEqual(world.outputRows, 24)
        XCTAssertEqual(world.inputRows, 2)
    }

    func testContentSizeMatchesSavitar1DefaultWindow() {
        let font = NSFont(name: "Monaco", size: 9) ?? NSFont.systemFont(ofSize: 9)
        let size = PaneDimensions.contentSize(columns: 80,
                                              outputRows: 24,
                                              inputRows: 2,
                                              font: font,
                                              dividerThickness: 1)

        XCTAssertEqual(size.width, 480, accuracy: 2)
        XCTAssertEqual(size.height, 270, accuracy: 2)
    }

    func testSplitPositionMatchesOutputRowCount() {
        let font = NSFont(name: "Monaco", size: 9) ?? NSFont.systemFont(ofSize: 9)
        let contentHeight: CGFloat = 270
        let split = PaneDimensions.splitPosition(outputRows: 24,
                                                 inputRows: 2,
                                                 font: font,
                                                 contentHeight: contentHeight,
                                                 dividerThickness: 1)
        XCTAssertEqual(split, 240, accuracy: 1)
    }

    func testInputPaneHeightMatchesTwoLineDefault() {
        let font = NSFont(name: "Monaco", size: 9) ?? NSFont.systemFont(ofSize: 9)
        XCTAssertEqual(PaneDimensions.inputPaneHeight(inputRows: 2, font: font), 30, accuracy: 1)
    }
}
