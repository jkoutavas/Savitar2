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

protocol TriggersAction: Action {
    func apply(oldTriggers: ReactionsState) -> ReactionsState
}

struct SetTriggersAction: TriggersAction {
    let triggers: [Trigger]

    init(triggers: [Trigger]) {
        self.triggers = triggers
    }

    func apply(oldTriggers: ReactionsState) -> ReactionsState {
        var result = oldTriggers
        result.triggerList.items = triggers
        return result
    }
}

protocol VariablesAction: Action {
    func apply(oldVariables: ReactionsState) -> ReactionsState
}

struct SetVariablesAction: Action {
    let variables: [Variable]

    init(variables: [Variable]) {
        self.variables = variables
    }

    func apply(oldVariables: ReactionsState) -> ReactionsState {
        var result = oldVariables
        result.variableList.items = variables
        return result
    }
}

struct ReactionsState: StateType {
    var triggerList: ItemListState<Trigger> = ItemListState<Trigger>()
    var variableList: ItemListState<Variable> = ItemListState<Variable>()
}

func reactionsReducer(action: Action, state: ReactionsState?) -> ReactionsState {
    guard var state = state else {
        return ReactionsState()
    }

    state = passActionToTriggers(action, state: state)
    state = passActionToVariables(action, state: state)

    state.triggerList.selection = passActionToSelection(action, selectionState: state.triggerList.selection)
    state.variableList.selection = passActionToSelection(action, selectionState: state.variableList.selection)

    return state
}

private func passActionToTriggers(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? TriggersAction else { return state }

    return action.apply(oldTriggers: state)
}

private func passActionToVariables(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? VariablesAction else { return state }

    return action.apply(oldVariables: state)
}

private func passActionToSelection(_ action: Action, selectionState: SelectionState) -> SelectionState {
    return selectionReducer(action, state: selectionState)
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
