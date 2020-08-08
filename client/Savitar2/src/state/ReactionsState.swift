//
//  ReactionsState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias SelectionState = Int?

protocol ReactionAction: Action {
    func apply(oldState: ReactionsState) -> ReactionsState
}

struct ItemListState<T>: StateType {
    var items: [T] = []
    var selection: SelectionState = nil

    func indexOf(objectID: SavitarObjectID) -> Int? {
        // swiftlint:disable force_cast
        return items.firstIndex(where: { ($0 as! SavitarObject).objectID == objectID })
        // swiftlint:enable force_cast
    }

    func item(objectID: SavitarObjectID) -> T? {
        guard let index = indexOf(objectID: objectID)
            else { return nil }

        return items[index]
    }
}

struct ReactionsState: StateType {
    var macroList: ItemListState<Macro> = ItemListState<Macro>()
    var triggerList: ItemListState<Trigger> = ItemListState<Trigger>()
}

func reactionsReducer(action: Action, state: ReactionsState?) -> ReactionsState {
    guard var state = state else {
        return ReactionsState()
    }

    if let reactionAction = action as? ReactionAction {
        return reactionAction.apply(oldState: state)
    } else {
        if action is MacroAction {
            var macroList = state.macroList
            macroList.items = macroList.items.compactMap { macroReducer(action, state: $0) }
            state.macroList = macroList
        } else if action is TriggerAction {
            var triggerList = state.triggerList
            triggerList.items = triggerList.items.compactMap { triggerReducer(action, state: $0) }
            state.triggerList = triggerList
        }

        return state
    }
}

struct UndoManagerProvider {
    var undoManager: UndoManager?
}

typealias ReactionsStore = Store<ReactionsState>

// A typealias will not work and only raise EXC_BAD_ACCESS exceptions. ¯\_(ツ)_/¯
protocol UndoableAction: Action, Undoable { }

protocol ReactionStoreSetter {
    func setStore(reactionsStore: ReactionsStore?)
}

func reactionsStore(undoManagerProvider: @escaping () -> UndoManager?) -> ReactionsStore {
    return ReactionsStore(
        reducer: reactionsReducer,
        state: nil,
        middleware: [
            //            removeIdempotentActionsMiddleware,
            //            loggingMiddleware,
            undoMiddleware(undoManagerProvider: undoManagerProvider)
        ]
    )
}
