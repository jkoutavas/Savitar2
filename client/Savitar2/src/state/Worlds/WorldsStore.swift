//
//  WorldsStore.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias WorldsStore = Store<WorldsState>

protocol WorldsStoreSetter {
    func setStore(_ store: WorldsStore?)
}

func worldsStore(undoManagerProvider: @escaping () -> UndoManager?) -> WorldsStore {
    return WorldsStore(
        reducer: worldsReducer,
        state: nil,
        middleware: [undoWorldsStateMiddleware(undoManagerProvider: undoManagerProvider)]
    )
}
