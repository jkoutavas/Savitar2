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

class AppContext {
    static let shared = AppContext()

    var isTerminating = false
    var prefs = AppPreferences()
    var speakerMan = SpeakerMan()
    var worldMan = WorldMan()

    func load() throws {
        globalStoreUndoManagerProvider.undoManager = UndoManager()

        try prefs.load()
    }

    func save() {
        do {
            try prefs.save()
        } catch {}
    }

    private init() {
    }
}


/*


struct AppContext {
    static var isTerminating = false
    static var prefs = AppPreferences()
    static var speakerMan = SpeakerMan()
    static var worldMan = WorldMan()

    static func load() throws {
        globalStoreUndoManagerProvider.undoManager = UndoManager()

        try prefs.load()
    }

    static func save() {
        do {
            try prefs.save()
        } catch {}
    }
}
*/
