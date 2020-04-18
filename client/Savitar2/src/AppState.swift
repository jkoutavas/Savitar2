//
//  AppState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType {
    var universalTriggers: [Trigger] = []
}

typealias AppStore = Store<AppState>

struct SetUniversalTriggersAction: Action {
    let newTriggers: [Trigger]

    init(triggers: [Trigger]) {
        self.newTriggers = triggers
    }
}

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let setUniversalTriggersAction as SetUniversalTriggersAction:
        state.universalTriggers = setUniversalTriggersAction.newTriggers
    default: break
    }

    return state
}

/*
func appStore() -> AppStore {
    return AppStore(
        reducer: appReducer,
        state: AppState(),
        middleware: []
    )
}
*/

var globalStore = Store<AppState>(reducer: appReducer, state: nil)
