//
//  MacroClickerTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class MacroClickerTests: XCTestCase {
    func testClickerLetterSlotsUseUnderscoreMacroNames() {
        XCTAssertEqual(ClickerSlotID.ten.defaultMacroName, "MACRO_A")
        XCTAssertEqual(ClickerSlotID.fifteen.defaultMacroName, "MACRO_F")
    }

    func testResolvedMacroRequiresExactNameMatch() {
        let macro = Macro()
        macro.name = "MACRO_A"
        macro.value = "Heynow!"

        let macros = [macro]
        XCTAssertNil(macros.first(where: { $0.name == "MACRO-A" }))
        XCTAssertEqual(macros.first(where: { $0.name == "MACRO_A" })?.value, "Heynow!")
    }

    func testCompassWedgeHitTestUsesTriangleNotOverlappingSquare() {
        let rect = NSRect(x: 0, y: 0, width: 30, height: 30)
        let northTip = NSPoint(x: 15, y: 2)

        XCTAssertTrue(ClickerAppearance.directionWedgeContains(northTip, in: rect, slot: .north))
        XCTAssertFalse(ClickerAppearance.directionWedgeContains(northTip, in: rect, slot: .northeast))
    }
}
