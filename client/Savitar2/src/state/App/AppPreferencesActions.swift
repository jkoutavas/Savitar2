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

// TODO: promote this to an undoable action once the App Preferences window is implemented
struct SetWorldPickerAtStartup: AppPreferencesAction {
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
        }
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
        return result
    }

    func inverse(context: AppPreferencesUndoContext) -> AppPreferencesUndoableAction? {
        return SetContinuousSpeechVoiceAction(context.continuousSpeechVoice())
    }
}
