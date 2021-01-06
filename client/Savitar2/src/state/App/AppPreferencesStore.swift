//
//  AppPreferencesStore.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/4/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias AppPreferencesStore = Store<AppPreferencesState>

func appPreferencesStore(undoManagerProvider: @escaping () -> UndoManager?) -> AppPreferencesStore {
    return AppPreferencesStore(
        reducer: appPreferencesReducer,
        state: nil,
        middleware: [undoAppPreferencesStateMiddleware(undoManagerProvider: undoManagerProvider)]
    )
}
