//
//  MacroPopupControllerTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class MacroPopupControllerTests: XCTestCase {
    private func macro(name: String, value: String) -> Macro {
        let macro = Macro()
        macro.name = name
        macro.value = value
        return macro
    }

    private func feed(_ controller: MacroPopupController,
                      _ keys: [MacroPopupController.Key],
                      macros: [Macro]) -> MacroPopupController.Action {
        var last: MacroPopupController.Action = .none
        for key in keys {
            last = controller.handle(key: key) { macros }
        }
        return last
    }

    func testShowsAtThreeCharacters() {
        let controller = MacroPopupController()
        let macros = [macro(name: "heal", value: "cast heal")]

        let atTwo = feed(controller, [.character("h"), .character("e")], macros: macros)
        XCTAssertEqual(atTwo, .update(.hide))
        XCTAssertEqual(controller.mode, .interested)

        let atThree = controller.handle(key: .character("a")) { macros }
        XCTAssertEqual(atThree, .update(.show(value: "cast heal", blink: false)))
        XCTAssertEqual(controller.mode, .showing)
    }

    func testFirstOfMultipleMatchesWins() {
        let controller = MacroPopupController()
        let macros = [
            macro(name: "heal", value: "cast heal"),
            macro(name: "health", value: "score")
        ]

        let action = feed(controller,
                          [.character("h"), .character("e"), .character("a")],
                          macros: macros)
        XCTAssertEqual(action, .update(.show(value: "cast heal", blink: false)))
    }

    func testWorldMacrosPrecedeUniversalInCombinedList() {
        let controller = MacroPopupController()
        // Caller supplies world-then-universal order (MacroClicker.candidateMacros).
        let macros = [
            macro(name: "MACRO_1", value: "world"),
            macro(name: "MACRO_1", value: "universal")
        ]

        let action = feed(controller,
                          [.character("M"), .character("A"), .character("C")],
                          macros: macros)
        XCTAssertEqual(action, .update(.show(value: "world", blink: false)))
    }

    func testReturnAcceptsFirstMatchValue() {
        let controller = MacroPopupController()
        let macros = [macro(name: "heal", value: "cast heal")]

        _ = feed(controller,
                 [.character("h"), .character("e"), .character("a")],
                 macros: macros)
        let action = controller.handle(key: .return) { macros }
        XCTAssertEqual(action, .accept(value: "cast heal", replaceLength: 3))
        XCTAssertEqual(controller.mode, .interested)
        XCTAssertEqual(controller.bufferLength, 0)
    }

    func testSpaceResets() {
        let controller = MacroPopupController()
        let macros = [macro(name: "heal", value: "cast heal")]

        _ = feed(controller,
                 [.character("h"), .character("e"), .character("a")],
                 macros: macros)
        let action = controller.handle(key: .space) { macros }
        XCTAssertEqual(action, .update(.hide))
        XCTAssertEqual(controller.mode, .interested)
        XCTAssertEqual(controller.bufferLength, 0)
    }

    func testNoMatchWhileShowingBecomesDismissed() {
        let controller = MacroPopupController()
        let macros = [macro(name: "heal", value: "cast heal")]

        _ = feed(controller,
                 [.character("h"), .character("e"), .character("a")],
                 macros: macros)
        let action = controller.handle(key: .character("x")) { macros }
        XCTAssertEqual(action, .update(.hide))
        XCTAssertEqual(controller.mode, .dismissed)

        // Further identifier chars are ignored until reset.
        let ignored = controller.handle(key: .character("y")) { macros }
        XCTAssertEqual(ignored, .none)
        XCTAssertEqual(controller.mode, .dismissed)
    }

    func testBackspaceRefilters() {
        let controller = MacroPopupController()
        let macros = [
            macro(name: "he", value: "short"),
            macro(name: "heal", value: "cast heal")
        ]

        _ = feed(controller,
                 [.character("h"), .character("e"), .character("a"), .character("l")],
                 macros: macros)
        XCTAssertEqual(controller.mode, .showing)

        let afterBackspace = controller.handle(key: .backspace) { macros }
        XCTAssertEqual(afterBackspace, .update(.show(value: "cast heal", blink: false)))

        _ = controller.handle(key: .backspace) { macros } // "he"
        let atOne = controller.handle(key: .backspace) { macros } // "h"
        XCTAssertEqual(atOne, .update(.hide))
        XCTAssertEqual(controller.mode, .interested)
    }

    func testBlinkWhenBufferEqualsMatchedNameLength() {
        let controller = MacroPopupController()
        let macros = [macro(name: "heal", value: "cast heal")]

        let action = feed(controller,
                          [.character("h"), .character("e"), .character("a"), .character("l")],
                          macros: macros)
        XCTAssertEqual(action, .update(.show(value: "cast heal", blink: true)))
    }

    func testTooltipTextTruncatesAtForty() {
        let long = String(repeating: "x", count: 45)
        let truncated = MacroPopupController.tooltipText(for: long)
        XCTAssertEqual(truncated.count, 41) // 40 + ellipsis
        XCTAssertTrue(truncated.hasSuffix("…"))
        XCTAssertEqual(MacroPopupController.tooltipText(for: "short"), "short")
    }

    func testCaseSensitivePrefix() {
        let controller = MacroPopupController()
        let macros = [macro(name: "Heal", value: "cast heal")]

        let action = feed(controller,
                          [.character("h"), .character("e"), .character("a")],
                          macros: macros)
        // Never entered Showing, so mode stays Interested (v1).
        XCTAssertEqual(action, .update(.hide))
        XCTAssertEqual(controller.mode, .interested)
    }

    func testKeyMapping() {
        XCTAssertEqual(MacroPopupController.key(fromEventKeyCode: Keycode.returnKey, characters: "\r"),
                       .return)
        XCTAssertEqual(MacroPopupController.key(fromEventKeyCode: Keycode.delete, characters: "\u{7f}"),
                       .backspace)
        XCTAssertEqual(MacroPopupController.key(fromEventKeyCode: Keycode.space, characters: " "),
                       .space)
        XCTAssertEqual(MacroPopupController.key(fromEventKeyCode: 0, characters: "a"),
                       .character("a"))
        XCTAssertEqual(MacroPopupController.key(fromEventKeyCode: 0, characters: "-"),
                       .invalid)
    }
}
