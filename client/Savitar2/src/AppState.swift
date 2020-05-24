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
    guard let state = state else {
        return ReactionsState()
    }

    guard let reactionAction = action as? ReactionAction else { return state }
    return reactionAction.apply(oldState: state)
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
