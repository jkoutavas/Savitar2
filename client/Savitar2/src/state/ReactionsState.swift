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
}

struct ReactionsState: StateType {
    var triggerList: ItemListState<Trigger> = ItemListState<Trigger>()
    var variableList: ItemListState<Variable> = ItemListState<Variable>()
}

func reactionsReducer(action: Action, state: ReactionsState?) -> ReactionsState {
    guard var state = state else {
        return ReactionsState()
    }

    if let reactionAction = action as? ReactionAction {
        return reactionAction.apply(oldState: state)
    } else {
        if action is TriggerAction {
            var triggerList = state.triggerList
            triggerList.items = triggerList.items.compactMap { triggerReducer(action, state: $0) }
            state.triggerList = triggerList
        } else if action is VariableAction {
            var variableList = state.variableList
            variableList.items = variableList.items.compactMap { variableReducer(action, state: $0) }
            state.variableList = variableList
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
