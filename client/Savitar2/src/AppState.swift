//
//  AppState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias SelectionState = Int?

protocol ApplicableAction: Action {
    func apply(oldState: ReactionsState) -> ReactionsState
}

protocol TriggerSelectionAction: ApplicableAction {
}

struct SelectTriggerAction: TriggerSelectionAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.selection = selection
        return result
    }
}

protocol VariableSelectionAction: ApplicableAction {
}

struct SelectVariableAction: VariableSelectionAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.variableList.selection = selection
        return result
    }
}

struct ItemListState<T>: StateType {
    var items: [T] = []
    var selection: SelectionState = nil
}

protocol TriggersAction: ApplicableAction {
}

struct SetTriggersAction: TriggersAction {
    let triggers: [Trigger]

    init(triggers: [Trigger]) {
        self.triggers = triggers
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.items = triggers
        return result
    }
}

protocol VariablesAction: ApplicableAction {
}

struct SetVariablesAction: VariablesAction {
    let variables: [Variable]

    init(variables: [Variable]) {
        self.variables = variables
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
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
    state = passActionToTriggerSelection(action, state: state)
    state = passActionToVariableSelection(action, state: state)

    return state
}

private func passActionToTriggers(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? TriggersAction else { return state }

    return action.apply(oldState: state)
}

private func passActionToVariables(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? VariablesAction else { return state }

    return action.apply(oldState: state)
}

private func passActionToTriggerSelection(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? TriggerSelectionAction else { return state }

    return action.apply(oldState: state)
}

private func passActionToVariableSelection(_ action: Action, state: ReactionsState) -> ReactionsState {
    guard let action = action as? VariableSelectionAction else { return state }

    return action.apply(oldState: state)
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
