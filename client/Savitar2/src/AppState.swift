//
//  AppState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct ItemListState<T>: StateType {
    var items: [T] = []
    var selection: SelectionState = nil
}

struct SetTriggersAction: Action {
    let triggers: [Trigger]

    init(triggers: [Trigger]) {
        self.triggers = triggers
    }
}

struct SetVariablesAction: Action {
    let variables: [Variable]

    init(variables: [Variable]) {
        self.variables = variables
    }
}

struct ReactionsState: StateType {
    var triggerList: ItemListState<Trigger> = ItemListState<Trigger>()
    var variableList: ItemListState<Variable> = ItemListState<Variable>()
}

func reactionsReducer(action: Action, state: ReactionsState?) -> ReactionsState {
    var state = state ?? ReactionsState()

    switch action {
    case let action as SetTriggersAction:
        state.triggerList.items = action.triggers
    case let action as SetVariablesAction:
        state.variableList.items = action.variables
    default: break
    }

    return state
}

typealias ReactionsStore = Store<ReactionsState>

func reactionsStore(undoManager: UndoManager) -> ReactionsStore {

    return ReactionsStore(
        reducer: reactionsReducer,
        state: nil
/*
        middleware: [
            removeIdempotentActionsMiddleware,
            loggingMiddleware,
            undoMiddleware(undoManager: undoManager)
        ]
*/
    )
}

var globalStore = reactionsStore(undoManager: UndoManager())
