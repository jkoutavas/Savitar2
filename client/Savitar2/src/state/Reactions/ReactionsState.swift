//
//  ReactionsState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct ReactionsState: StateType {
    var macroList = ItemListState<Macro>()
    var triggerList = ItemListState<Trigger>()
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
