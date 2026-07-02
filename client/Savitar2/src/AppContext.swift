//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

private var appUndoManagerInstance = UndoManager()

class AppContext {
    static let shared = AppContext()

    var prefs: AppPreferences { appPrefsStore.state.prefs }
    var speakerMan: SpeakerMan
    var worldMan: WorldMan

    internal var isTerminating: Bool

    var appPrefsStore = appPreferencesStore(undoManagerProvider: { AppContext.shared.appUndoManager })
    var universalReactionsStore = reactionsStore(undoManagerProvider: { appUndoManagerInstance })
    var worldPickerStore = worldsStore(undoManagerProvider: { appUndoManagerInstance })

    internal var appPrefsWindowController: AppSettingsWindowController?
    internal var universalEventsWindowController: NSWindowController?
    internal var worldPickerWindowController: NSWindowController?

    // swiftlint:disable:this weak_delegate
    private var universalEventsWindowDelegate: UniversalEventsWindowDelegate?
    private var worldPickerWindowDelegate: WorldPickerWindowDelegate?

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

        universalEventsWindowDelegate = UniversalEventsWindowDelegate(self)
        worldPickerWindowDelegate = WorldPickerWindowDelegate(self)
    }

    var appUndoManager: UndoManager { appUndoManagerInstance }

    func appPrefsWindowDidClose() {
        appPrefsWindowController = nil
    }

    func load() {
        prefs.load()
    }

    func save() {
        prefs.save()
    }

    func prepareForTermination() {
        isTerminating = true
        prefs.openSessions = WindowRestoration.captureOpenSessions(from: self)
        save()
    }

    func appIsTerminating() {
        if !isTerminating {
            prepareForTermination()
        } else {
            save()
        }
    }

    func restoreSavedWindows() {
        let sessions = prefs.openSessions
        guard !sessions.isEmpty else { return }
        WindowRestoration.restoreSavedSessions(sessions, in: self)
    }

    func showAppPrefsWindow(selecting pane: AppSettingsPane = .startup) {
        if let windowController = appPrefsWindowController {
            windowController.selectPane(pane)
            windowController.window?.makeKeyAndOrderFront(self)
            return
        }

        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "AppPrefs", bundle: bundle)
        guard let windowController = storyboard.instantiateInitialController() as? AppSettingsWindowController else { return }

        appPrefsWindowController = windowController
        windowController.initialPane = pane

        if let contentController = windowController.contentViewController as? AppPrefsViewController {
            contentController.store = appPrefsStore
        }

        windowController.showWindow(self)
        windowController.selectPane(pane)
    }

    func showContinuousSpeechPrefsWindow() {
        showAppPrefsWindow(selecting: .speech)
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
            appPrefsStore.dispatch(SetShowEventsWindowAtStartupAction(true))
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

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        return appUndoManagerInstance
    }

    func windowWillClose(_: Notification) {
        // Only remove the startupEventsWindow flag if the user has closed the window. (windowWillClose gets called
        // on application termination too.)
        if !ctx.isTerminating {
            ctx.appPrefsStore.dispatch(SetShowEventsWindowAtStartupAction(false))
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
        return appUndoManagerInstance
    }

    func windowWillClose(_: Notification) {
        ctx.worldPickerWindowController = nil
    }
}
