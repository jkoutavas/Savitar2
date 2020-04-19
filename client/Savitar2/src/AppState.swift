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
    var worldDocuments: [Document] = []
}

typealias AppStore = Store<AppState>

struct AddWorldDocumentAction: Action {
    let document: Document

    init(document: Document) {
        self.document = document
    }
}

struct RemoveWorldDocumentAction: Action {
    let document: Document

    init(document: Document) {
        self.document = document
    }
}

struct SetUniversalTriggersAction: Action {
    let triggers: [Trigger]

    init(triggers: [Trigger]) {
        self.triggers = triggers
    }
}

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let action as AddWorldDocumentAction:
        state.worldDocuments.append(action.document)
    case let action as RemoveWorldDocumentAction:
        state.worldDocuments.remove(object: action.document)
    case let action as SetUniversalTriggersAction:
        state.universalTriggers = action.triggers
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
