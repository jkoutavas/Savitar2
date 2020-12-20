//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

var appUndoManager = UndoManager()

class AppContext {
    static let shared = AppContext()

    var isTerminating: Bool
    var prefs: AppPreferences
    var speakerMan: SpeakerMan
    var worldMan: WorldMan

    var universalReactionsStore = reactionsStore(undoManagerProvider: { appUndoManager })

    var universalEventsWindowController: NSWindowController?
    var worldPickerController: NSWindowController?

    // swiftlint:disable weak_delegate
    var universalEventsWindowDelegate: UniversalEventsWindowDelegate?
    var worldPickerWindowDelegate: WorldPickerWindowDelegate?
    // swiftlint:enable weak_delegate

    // TODO: this is a good start. See Savitar 1.x's "CViewAppMac.cp" for references to Savitar's
    // "editing keys" (not support at this time) and the means used to add all menu command shortcut keys
    let reservedKeyList = ["return", "space", "up arrow", "down arrow", "left arrow", "right arrow"]

    func load() throws {
        try prefs.load()
    }

    func save() {
        do {
            try prefs.save()
        } catch {}
    }

    private init() {
        isTerminating = false

        prefs = AppPreferences()
        speakerMan = SpeakerMan()
        worldMan = WorldMan()

        universalEventsWindowDelegate = UniversalEventsWindowDelegate()
        worldPickerWindowDelegate = WorldPickerWindowDelegate()
    }
}

class UniversalEventsWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
         return appUndoManager
     }

     func windowWillClose(_ notification: Notification) {
         // Only remove the startupEventsWindow flag if the user has closed the window. (windowWillClose gets called
         // on application termination too.)
         if !AppContext.shared.isTerminating {
             AppContext.shared.prefs.flags.remove(.startupEventsWindow)
             AppContext.shared.save()
         }
         AppContext.shared.universalEventsWindowController = nil
     }
}

class WorldPickerWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
          AppContext.shared.worldPickerController = nil
    }
}
