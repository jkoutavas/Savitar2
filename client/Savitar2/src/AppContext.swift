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

    var prefs: AppPreferences {appPrefsStore.state.prefs}
    var speakerMan: SpeakerMan
    var worldMan: WorldMan

    internal var isTerminating: Bool

    var appPrefsStore = appPreferencesStore(undoManagerProvider: { appUndoManager })
    var universalReactionsStore = reactionsStore(undoManagerProvider: { appUndoManager })
    var worldPickerStore = worldsStore(undoManagerProvider: { appUndoManager })

    internal var speechPrefsWindowController: NSWindowController?
    internal var universalEventsWindowController: NSWindowController?
    internal var worldPickerWindowController: NSWindowController?

    // swiftlint:disable weak_delegate
    private var speechPrefsWindowDelegate: SpeechPrefsWindowDelegate?
    private var universalEventsWindowDelegate: UniversalEventsWindowDelegate?
    private var worldPickerWindowDelegate: WorldPickerWindowDelegate?
    // swiftlint:enable weak_delegate

    // TODO: this is a good start. See Savitar 1.x's "CViewAppMac.cp" for references to Savitar's
    // "editing keys" (not support at this time) and the means used to add all menu command shortcut keys
    let reservedKeyList = ["return", "space", "up arrow", "down arrow", "left arrow", "right arrow"]

    static func hasContinuousSpeech() -> Bool {
        // AVSpeechSynthesizer supports queued utterances and is only fully implemented in macOS 10.15 or later
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return (version.majorVersion == 10 && version.minorVersion >= 15) || version.majorVersion >= 11
    }
    
    private init() {
        isTerminating = false

        speakerMan = AppContext.hasContinuousSpeech() ? SpeakerManAV() : SpeakerManNS()
        worldMan = WorldMan()

        speechPrefsWindowDelegate = SpeechPrefsWindowDelegate(self)
        universalEventsWindowDelegate = UniversalEventsWindowDelegate(self)
        worldPickerWindowDelegate = WorldPickerWindowDelegate(self)
    }

    func load() {
        prefs.load()
    }

    func save() {
        prefs.save()
    }

    func appIsTerminating() {
        isTerminating = true
        save()
    }
    
    func showContinuousSpeechPrefsWindow() {
        if speechPrefsWindowController != nil {
            speechPrefsWindowController?.window?.makeKeyAndOrderFront(self)
            return
        }
        
        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "SpeechPrefs", bundle: bundle)
        guard let windowController = storyboard.instantiateInitialController() as? NSWindowController else { return }
        guard let window = windowController.window else { return }

        speechPrefsWindowController = windowController
        window.delegate = speechPrefsWindowDelegate

        if let contentController = window.contentViewController as? SpeechPrefsViewController {
            contentController.store = AppContext.shared.appPrefsStore
            windowController.windowFrameAutosaveName = "SpeechPrefsWindowFrame"
            windowController.showWindow(self)
        }
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
            appPrefsStore.dispatch(SetWorldPickerAtStartup(true))
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

class SpeechPrefsWindowDelegate: NSObject, NSWindowDelegate {
    var ctx: AppContext
    init(_ ctx: AppContext) {
        self.ctx = ctx
    }
    
    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        return appUndoManager
    }

    func windowWillClose(_: Notification) {
        ctx.speechPrefsWindowController = nil
    }
}

class UniversalEventsWindowDelegate: NSObject, NSWindowDelegate {
    var ctx: AppContext
    init(_ ctx: AppContext) {
        self.ctx = ctx
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        return appUndoManager
    }

    func windowWillClose(_: Notification) {
        // Only remove the startupEventsWindow flag if the user has closed the window. (windowWillClose gets called
        // on application termination too.)
        if !ctx.isTerminating {
            ctx.appPrefsStore.dispatch(SetWorldPickerAtStartup(false))
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

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        return appUndoManager
    }
    
    func windowWillClose(_: Notification) {
        ctx.worldPickerWindowController = nil
    }
}
