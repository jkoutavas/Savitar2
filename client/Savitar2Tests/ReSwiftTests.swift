//
//  ReSwiftTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/14/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import XCTest
import ReSwift

/*
    This set of tests are based on watered-down version we use in Savitar's ReactionsState
    (We're using ItemListState<Foo> instead of using ItemListState<triggersList> and ItemListState<macrosList>)
 */
class TestSubscriber<T>: StoreSubscriber {
    var receivedList: T!
    var newStateCallCount = 0

    func newState(state: T) {
        receivedList = state
        newStateCallCount += 1
    }
}

struct Foo: Equatable {
    var name: String?

    init(_ name: String) {
        self.name = name
    }
}

struct TestAppState: StateType {
    var itemList: ItemListState<Foo>?
}

struct ItemListState<T: Equatable>: StateType {
    var items: [T]
    var selection: Int?

    init(_ items: [T], _ selection: Int? = nil) {
        self.items = items
        self.selection = selection
    }
}

struct SetItemsAction: Action {
    let itemList: ItemListState<Foo>
    static let type = "SetItemsAction"

    init (_ itemList: ItemListState<Foo>) {
        self.itemList = itemList
    }
}

struct TestReducer {
     func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        var state = state ?? TestAppState()

        switch action {
        case let action as SetItemsAction:
            state.itemList = action.itemList
            return state
        default:
            return state
        }
    }
}

class ReSwift: XCTestCase {
    // The traditional way to do substate subscription
    func testSubstateSelectSubscription() {
        let reducer = TestReducer()
        let state = TestAppState()
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestSubscriber<ItemListState<Foo>?>()
        store.subscribe(subscriber) {
            $0.select { $0.itemList }
        }

        let foo = Foo("heynow")
        store.dispatch(SetItemsAction(ItemListState<Foo>([foo], 23)))
        XCTAssertEqual(subscriber.receivedList?.items.count, 1)
        XCTAssertEqual(subscriber.receivedList?.items[0].name, "heynow")
        XCTAssertEqual(subscriber.receivedList?.selection, 23)
    }

    // Keypath is new with v6.0 of ReSwift
    func testSubstateSelectKeypathSubscription() {
        let reducer = TestReducer()
        let state = TestAppState()
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestSubscriber<ItemListState<Foo>?>()
        store.subscribe(subscriber) {
            $0.select(\.itemList)
        }

        let foo = Foo("heythen")
        store.dispatch(SetItemsAction(ItemListState<Foo>([foo], 24)))
        XCTAssertEqual(subscriber.receivedList?.items.count, 1)
        XCTAssertEqual(subscriber.receivedList?.items[0].name, "heythen")
        XCTAssertEqual(subscriber.receivedList?.selection, 24)
    }
}
