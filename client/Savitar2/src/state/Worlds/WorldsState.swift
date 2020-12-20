//
//  WorldsState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct WorldsState: StateType {
    var worldList = ItemListState<World>()
}

func worldsReducer(action: Action, state: WorldsState?) -> WorldsState {
    guard let state = state else {
        return WorldsState()
    }

    if let worldAction = action as? WorldAction {
        return worldAction.apply(oldState: state)
    } else {
        return state
    }
}
