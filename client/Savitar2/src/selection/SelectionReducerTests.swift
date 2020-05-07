//
//  SelectionReducerTests.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/28/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

@testable import reswift_jobs
import XCTest

// swiftlint:disable nesting

class SelectionReducerTests: XCTestCase {
    func testHandleAction_WithUnsupportedActionAndNil_ReturnsNil() {
        struct SomeAction: Action {}

        XCTAssertNil(selectionReducer(SomeAction(), state: nil))
    }

    func testHandleAction_WithUnsupportedActionAndState_ReturnsState() {
        struct SomeAction: Action {}
        let state = SelectionState(123)

        let result = selectionReducer(SomeAction(), state: SelectionState(123))

        XCTAssertEqual(result, state)
    }

    func testHandleAction_WithDeselectAndNil_ReturnsNil() {
        let state = SelectionState.none

        let result = selectionReducer(SelectionAction.deselect, state: state)

        XCTAssertNil(result)
    }

    func testHandleAction_WithDeselectAndState_ReturnsNil() {
        let state = SelectionState(456)

        let result = selectionReducer(SelectionAction.deselect, state: state)

        XCTAssertNil(result)
    }

    func testHandleAction_WithSelectionChangeAndNil_ReturnsNewState() {
        let state = SelectionState.none
        let newValue = 9812

        let result = selectionReducer(SelectionAction.select(row: newValue), state: state)

        XCTAssertEqual(result, SelectionState(newValue))
    }

    func testHandleAction_WithSelectionStateAndState_ReturnsNewState() {
        let state = SelectionState.none
        let newValue = 4466

        let result = selectionReducer(SelectionAction.select(row: newValue), state: state)

        XCTAssertEqual(result, SelectionState(newValue))
    }
}
