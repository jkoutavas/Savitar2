//
//  TriggerTextDropTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class TriggerTextDropTests: XCTestCase {
    func testDroppedOutputTextBecomesAnOutputTrigger() {
        let trigger = Trigger.fromDroppedOutputText("  You feel hungry \nYou are thirsty\n")
        XCTAssertEqual(trigger?.name, "You feel hungry")
        guard let trigger else {
            XCTFail("Expected a trigger")
            return
        }
        var line = "Then you feel hungry again"
        XCTAssertTrue(trigger.reactionTo(line: &line))
        line = "You are thirsty"
        XCTAssertFalse(trigger.reactionTo(line: &line))
    }

    func testBlankDroppedTextIsRejected() {
        XCTAssertNil(Trigger.fromDroppedOutputText("  \n\t"))
        XCTAssertNil(Trigger.fromDroppedOutputText(""))
    }

    func testPasteboardStringUsesFirstLine() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("Savitar2TriggerTextDropTests"))
        pasteboard.clearContents()
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("You feel hungry\nnext line", forType: .string)
        defer { pasteboard.clearContents() }

        let trigger = TriggerTableDataSource.trigger(fromDroppedOutputTextOn: pasteboard)
        XCTAssertEqual(trigger?.name, "You feel hungry")
    }

    func testInsertionIndexClampsToTheList() {
        XCTAssertEqual(TriggerTableDataSource.insertionIndex(proposedRow: -1, itemCount: 2), 0)
        XCTAssertEqual(TriggerTableDataSource.insertionIndex(proposedRow: 0, itemCount: 2), 0)
        XCTAssertEqual(TriggerTableDataSource.insertionIndex(proposedRow: 1, itemCount: 2), 1)
        XCTAssertEqual(TriggerTableDataSource.insertionIndex(proposedRow: 9, itemCount: 2), 2)
    }

    func testDropInsertsAndSelectsBetweenExistingTriggers() {
        let store = reactionsStore { nil }
        let source = TriggerTableDataSource()
        source.setStore(store)
        store.dispatch(InsertTriggerAction(trigger: Trigger(name: "first"), atIndex: 0))
        store.dispatch(InsertTriggerAction(trigger: Trigger(name: "third"), atIndex: 1))

        let dropped = Trigger.fromDroppedOutputText("second")
        let index = dropped.flatMap { source.insertTrigger($0, at: 1) }

        XCTAssertEqual(index, 1)
        XCTAssertEqual(store.state?.triggerList.items.map(\.name), ["first", "second", "third"])
        XCTAssertEqual(store.state?.triggerList.selection, 1)
    }
}
