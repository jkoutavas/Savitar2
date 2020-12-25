//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

private var appUndoManager = UndoManager()

class AppContext {
    static let shared = AppContext()

    var prefs: AppPreferences
    var speakerMan: SpeakerMan
    var worldMan: WorldMan

    internal var isTerminating: Bool

    var universalReactionsStore = reactionsStore(undoManagerProvider: { appUndoManager })
    var worldPickerStore = worldsStore(undoManagerProvider: { appUndoManager })

    internal var universalEventsWindowController: NSWindowController?
    internal var worldPickerWindowController: NSWindowController?

    // swiftlint:disable weak_delegate
    private var universalEventsWindowDelegate: UniversalEventsWindowDelegate?
    private var worldPickerWindowDelegate: WorldPickerWindowDelegate?
    // swiftlint:enable weak_delegate

    // TODO: this is a good start. See Savitar 1.x's "CViewAppMac.cp" for references to Savitar's
    // "editing keys" (not support at this time) and the means used to add all menu command shortcut keys
    let reservedKeyList = ["return", "space", "up arrow", "down arrow", "left arrow", "right arrow"]

    private init() {
        isTerminating = false

        prefs = AppPreferences()
        speakerMan = SpeakerMan()
        worldMan = WorldMan()

        universalEventsWindowDelegate = UniversalEventsWindowDelegate(self)
        worldPickerWindowDelegate = WorldPickerWindowDelegate(self)
    }

    func load() throws {
        try prefs.load()
    }

    func save() {
        do {
            try prefs.save()
        } catch {}
    }

    func appIsTerminating() {
        isTerminating = true
        save()
    }

    func showUniversalEventsWindow() {
        if universalEventsWindowController != nil {
             universalEventsWindowController?.window?.makeKeyAndOrderFront(self)
             return
         }

         let bundle = Bundle(for: Self.self)
         let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
         guard let windowController = storyboard.instantiateInitialController() as? NSWindowController else { return }
         guard let window = windowController.window else { return }

         universalEventsWindowController = windowController
         window.delegate = universalEventsWindowDelegate

         if let contentController = window.contentViewController as? EventsSplitViewController {
             contentController.store = universalReactionsStore
             windowController.windowFrameAutosaveName = "EventsWindowFrame"
             windowController.showWindow(self)
             prefs.flags.insert(.startupEventsWindow)
             save()
         }
    }

    func showWorldPicker() {
        if worldPickerWindowController != nil {
            worldPickerWindowController?.window?.makeKeyAndOrderFront(self)
            return
        }

        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "WorldPicker", bundle: bundle)
        guard let windowController = storyboard.instantiateInitialController() as? NSWindowController else { return }
        guard let window = windowController.window else { return }

        worldPickerWindowController = windowController
        window.delegate = worldPickerWindowDelegate

        if let contentController = window.contentViewController as? WorldPickerController {
            contentController.store = worldPickerStore
            windowController.windowFrameAutosaveName = "WorldPickerFrame"
            windowController.showWindow(self)
        }
    }
}

class UniversalEventsWindowDelegate: NSObject, NSWindowDelegate {
    var ctx: AppContext
    init(_ ctx: AppContext) {
        self.ctx = ctx
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
         return appUndoManager
     }

     func windowWillClose(_ notification: Notification) {
         // Only remove the startupEventsWindow flag if the user has closed the window. (windowWillClose gets called
         // on application termination too.)
         if !ctx.isTerminating {
             ctx.prefs.flags.remove(.startupEventsWindow)
             ctx.save()
         }
         ctx.universalEventsWindowController = nil
     }
}

class WorldPickerWindowDelegate: NSObject, NSWindowDelegate {
    var ctx: AppContext
    init(_ ctx: AppContext) {
        self.ctx = ctx
    }

    func windowWillClose(_ notification: Notification) {
          ctx.worldPickerWindowController = nil
    }
}
