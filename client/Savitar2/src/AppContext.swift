//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

var globalStoreUndoManagerProvider = UndoManagerProvider()
var globalStore = reactionsStore(undoManagerProvider: { globalStoreUndoManagerProvider.undoManager })

struct AppContext {
    static var prefs = AppPreferences()
    static var worldMan = WorldMan()

    static func load() throws {
        globalStoreUndoManagerProvider.undoManager = UndoManager()

        try prefs.load()
    }

    static func save() throws {
        try prefs.save()
    }
}
