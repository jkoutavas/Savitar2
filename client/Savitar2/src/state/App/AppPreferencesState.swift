//
//  AppPreferencesState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import ReSwift

struct AppPreferencesState: StateType {
    var prefs = AppPreferences()
}

func appPreferencesReducer(action: Action, state: AppPreferencesState?) -> AppPreferencesState {
    guard let state = state else {
        return AppPreferencesState()
    }

    if let prefAction = action as? AppPreferencesAction {
        return prefAction.apply(oldState: state)
    } else {
        return state
    }
}
