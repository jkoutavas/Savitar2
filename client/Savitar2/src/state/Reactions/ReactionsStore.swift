//
//  ReactionsStore.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias ReactionsStore = Store<ReactionsState>

protocol ReactionStoreSetter {
    func setStore(reactionsStore: ReactionsStore?)
}

func reactionsStore(undoManagerProvider: @escaping () -> UndoManager?) -> ReactionsStore {
    return ReactionsStore(
        reducer: reactionsReducer,
        state: nil,
        middleware: [undoReactionsStateMiddleware(undoManagerProvider: undoManagerProvider)]
    )
}
