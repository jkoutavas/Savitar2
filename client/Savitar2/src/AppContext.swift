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

    // TODO: this is a good start. See Savitar 1.x's "CViewAppMac.cp" for references to Savitar's
    // "editing keys" (not support at this time) and the means used to add all menu command shortcut keys
    let reservedKeyList = ["return", "space", "up arrow", "down arrow", "left arrow", "right arrow"]

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
