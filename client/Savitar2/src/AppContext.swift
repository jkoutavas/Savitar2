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
    internal var worldPickerWindowController: WorldPickerWindowController?

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
    }

    var appUndoManager: UndoManager { appUndoManagerInstance }

    func appPrefsWindowDidClose() {
        appPrefsWindowController = nil
    }

    func worldPickerWindowDidClose() {
        worldPickerWindowController = nil
    }

    func load() {
        prefs.load()
        AppAppearance.apply(prefs.appearanceMode)
    }

    func save() {
        prefs.save()
    }

    func restoreFactoryDefaults() {
        appPrefsStore.dispatch(RestoreFactoryDefaultsAction())
        closeUtilityWindowsAfterFactoryReset()
        AppAppearance.apply(prefs.appearanceMode)
        NotificationCenter.default.post(name: .savitarColorsChanged, object: nil)
    }

    private func closeUtilityWindowsAfterFactoryReset() {
        worldPickerWindowController?.window?.close()
        worldPickerWindowController = nil
        universalEventsWindowController?.window?.close()
        universalEventsWindowController = nil
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
        guard let windowController = storyboard.instantiateInitialController()
            as? AppSettingsWindowController else { return }

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
        if let controller = universalEventsWindowController as? EventsWindowController {
            controller.window?.makeKeyAndOrderFront(self)
            return
        }

        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? EventsWindowController else { return }

        universalEventsWindowController = controller
        controller.reactionsStore = universalReactionsStore
        controller.undoManagerProvider = { appUndoManagerInstance }
        controller.onWillClose = { [weak self] isTerminating in
            guard let self else { return }
            if !isTerminating {
                appPrefsStore.dispatch(SetShowEventsWindowAtStartupAction(false))
                save()
            }
            universalEventsWindowController = nil
        }
        controller.present(autosaveName: "EventsWindowFrame", title: "Events Window")
        appPrefsStore.dispatch(SetShowEventsWindowAtStartupAction(true))
        save()
    }

    func showWorldPicker() {
        if worldPickerWindowController != nil {
            worldPickerWindowController?.window?.makeKeyAndOrderFront(self)
            return
        }

        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "WorldPicker", bundle: bundle)
        guard let windowController = storyboard.instantiateInitialController()
            as? WorldPickerWindowController else { return }
        guard let window = windowController.window else { return }

        worldPickerWindowController = windowController

        if let contentController = window.contentViewController as? WorldPickerController {
            contentController.store = worldPickerStore
            windowController.present()
        }
    }
}
