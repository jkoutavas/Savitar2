//
//  AppPreferencesActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import ReSwift

protocol AppPreferencesAction: Action {
    func apply(oldState: AppPreferencesState) -> AppPreferencesState
}

protocol AppPreferencesUndoableAction: Action {
    /// Name used for e.g. "Undo" menu items.
    var name: String { get }

    var notUndoable: NotUndoable { get }

    func inverse(context: AppPreferencesUndoContext) -> AppPreferencesUndoableAction?
}

extension AppPreferencesUndoableAction where Self: AppPreferencesAction {
    var notUndoable: NotUndoable {
        return NotUndoable(self)
    }
}

struct SetPrefsFlagAction: AppPreferencesAction {
    let flag: PrefsFlags
    let enabled: Bool

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        if enabled {
            result.prefs.flags.insert(flag)
        } else {
            result.prefs.flags.remove(flag)
        }
        result.prefs.save()
        return result
    }
}

struct SetShowEventsWindowAtStartupAction: AppPreferencesAction {
    let enabled: Bool

    init(_ enabled: Bool) {
        self.enabled = enabled
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        if enabled {
            result.prefs.flags.insert(.startupEventsWindow)
        } else {
            result.prefs.flags.remove(.startupEventsWindow)
        }
        result.prefs.save()
        return result
    }
}

struct RestoreFactoryDefaultsAction: AppPreferencesAction {
    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        var result = AppPreferencesState()
        do {
            try result.prefs.loadFactoryDefaults()
        } catch {
            return oldState
        }
        result.prefs.openSessions = []
        WindowRestoration.clearUtilityWindowState()
        result.prefs.save()
        return result
    }
}

struct SetUpdatingEnabledAction: AppPreferencesAction {
    let enabled: Bool

    init(_ enabled: Bool) {
        self.enabled = enabled
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        result.prefs.updatingEnabled = enabled
        result.prefs.save()
        return result
    }
}

struct SetAppAppearanceModeAction: AppPreferencesAction {
    let mode: AppAppearanceMode

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        result.prefs.appearanceMode = mode
        result.prefs.save()
        AppAppearance.apply(mode)
        return result
    }
}

// MARK: Undoable

struct SetContinuousSpeechEnabledAction: AppPreferencesUndoableAction, AppPreferencesAction {
    let enabled: Bool

    var name = "Toggle Continuous Speech"

    init(_ enabled: Bool) {
        self.enabled = enabled
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        result.prefs.continuousSpeechEnabled = enabled
        result.prefs.save()
        return result
    }

    func inverse(context _: AppPreferencesUndoContext) -> AppPreferencesUndoableAction? {
        return SetContinuousSpeechEnabledAction(!enabled)
    }
}

struct SetShowStartupPickerAction: AppPreferencesUndoableAction, AppPreferencesAction {
    let enabled: Bool

    var name = "Toggle Show World Picker at Startup"

    init(_ enabled: Bool) {
        self.enabled = enabled
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        if enabled {
            result.prefs.flags.insert(.startupPicker)
        } else {
            result.prefs.flags.remove(.startupPicker)
            result.prefs.openSessions.removeAll {
                if case .worldPickerWindow = $0 { return true }
                return false
            }
        }
        result.prefs.save()
        return result
    }

    func inverse(context _: AppPreferencesUndoContext) -> AppPreferencesUndoableAction? {
        return SetShowStartupPickerAction(!enabled)
    }
}

struct SetContinuousSpeechRateAction: AppPreferencesUndoableAction, AppPreferencesAction {
    let rate: Int

    var name = "Change Speech Rate"

    init(_ rate: Int) {
        self.rate = rate
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        result.prefs.continuousSpeechRate = rate
        result.prefs.save()
        return result
    }

    func inverse(context: AppPreferencesUndoContext) -> AppPreferencesUndoableAction? {
        return SetContinuousSpeechRateAction(context.continuousSpeechRate())
    }
}

struct SetContinuousSpeechVoiceAction: AppPreferencesUndoableAction, AppPreferencesAction {
    let voice: String

    var name = "Change Speech Voice"

    init(_ voice: String) {
        self.voice = voice
    }

    func apply(oldState: AppPreferencesState) -> AppPreferencesState {
        let result = oldState
        result.prefs.continuousSpeechVoice = voice
        result.prefs.save()
        return result
    }

    func inverse(context: AppPreferencesUndoContext) -> AppPreferencesUndoableAction? {
        return SetContinuousSpeechVoiceAction(context.continuousSpeechVoice())
    }
}
