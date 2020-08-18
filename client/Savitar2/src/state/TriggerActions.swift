//
//  TriggerActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/17/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

struct SelectTriggerAction: ReactionAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.selection = selection
        return result
    }
}

struct SetTriggersAction: ReactionAction {
    let triggers: [Trigger]

    init(triggers: [Trigger]) {
        self.triggers = triggers
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.items = triggers
        return result
    }
}

enum TriggerAction: UndoableAction {
    case disable(SavitarObjectID)
    case enable(SavitarObjectID)
    case rename(SavitarObjectID, name: String)
    case setAppearance(SavitarObjectID, type: TrigAppearance)
    case setAudioType(SavitarObjectID, type: TrigAudioType)
    case setBackColor(SavitarObjectID, color: NSColor)
    case setFace(SavitarObjectID, face: TrigFace)
    case setForeColor(SavitarObjectID, color: NSColor)
    case setMatching(SavitarObjectID, matching: TrigMatching)
    case setSayText(SavitarObjectID, text: String)
    case setSound(SavitarObjectID, name: String)
    case setSpecifier(SavitarObjectID, specifier: TrigSpecifier)
    case setSubstitution(SavitarObjectID, substitution: String)
    case setType(SavitarObjectID, type: TrigType)
    case setVoice(SavitarObjectID, name: String)
    case setWordEnding(SavitarObjectID, wordEnding: String)
    case toggleCaseSensitive(SavitarObjectID)
    case toggleUseSubstitution(SavitarObjectID)

    // MARK: Undoable

    var isUndoable: Bool { return true }

    var name: String {
        switch self {
        case .enable: return "Enable Trigger"
        case .disable: return "Disable Trigger"
        case .rename: return "Rename Trigger"
        case .setAppearance: return "Change Trigger Appearance Type"
        case .setAudioType: return "Change Trigger Audio Type"
        case .setBackColor: return "Change Trigger Back Color"
        case .setFace: return "Change Trigger Face"
        case .setForeColor: return "Change Trigger Fore Color"
        case .setMatching: return "Change Trigger Matching"
        case .setSayText: return "Change Trigger Spoken Text"
        case .setSound: return "Change Trigger Sound"
        case .setSpecifier: return "Change Trigger Specifier"
        case .setSubstitution: return "Change Trigger Substitution"
        case .setType: return "Change Trigger Type"
        case .setVoice: return "Change Trigger Voice"
        case .setWordEnding: return "Change Trigger Word Ending"
        case .toggleCaseSensitive: return "Change Trigger Case Sensitive"
        case .toggleUseSubstitution: return "Change Trigger Use Substitution"
        }
    }

    func inverse(context: UndoActionContext) -> UndoableAction? {
        switch self {
        case let .disable(triggerID):
            return TriggerAction.enable(triggerID)

        case let .enable(triggerID):
            return TriggerAction.disable(triggerID)

        case let .rename(triggerID, name: _):
            guard let prev = context.triggerName(triggerID: triggerID) else { return nil }
            return TriggerAction.rename(triggerID, name: prev)

        case let .setAppearance(triggerID, type: _):
            guard let prev = context.triggerAppearance(triggerID: triggerID) else { return nil }
            return TriggerAction.setAppearance(triggerID, type: prev)

        case let .setAudioType(triggerID, type: _):
            guard let prev = context.triggerAudioType(triggerID: triggerID) else { return nil }
            return TriggerAction.setAudioType(triggerID, type: prev)

        case let .setBackColor(triggerID, color: _):
            guard let prev = context.triggerBackColor(triggerID: triggerID) else { return nil }
            return TriggerAction.setBackColor(triggerID, color: prev)

        case let .setFace(triggerID, face: _):
            guard let prev = context.triggerFace(triggerID: triggerID) else { return nil }
            return TriggerAction.setFace(triggerID, face: prev)

        case let .setForeColor(triggerID, color: _):
            guard let prev = context.triggerForeColor(triggerID: triggerID) else { return nil }
            return TriggerAction.setForeColor(triggerID, color: prev)

        case let .setMatching(triggerID, matching: _):
            guard let prev = context.triggerMatching(triggerID: triggerID) else { return nil }
            return TriggerAction.setMatching(triggerID, matching: prev)

        case let .setSayText(triggerID, text: _):
            guard let prev = context.triggerSayText(triggerID: triggerID) else { return nil }
            return TriggerAction.setSayText(triggerID, text: prev)

        case let .setSound(triggerID, name: _):
            guard let prev = context.triggerSound(triggerID: triggerID) else { return nil }
            return TriggerAction.setSound(triggerID, name: prev)

        case let .setSpecifier(triggerID, specifier: _):
            guard let prev = context.triggerSpecifier(triggerID: triggerID) else { return nil }
            return TriggerAction.setSpecifier(triggerID, specifier: prev)

        case let .setSubstitution(triggerID, substitution: _):
            guard let prev = context.triggerSubstitution(triggerID: triggerID) else { return nil }
            return TriggerAction.setSubstitution(triggerID, substitution: prev)

        case let .setType(triggerID, type: _):
            guard let prev = context.triggerType(triggerID: triggerID) else { return nil }
            return TriggerAction.setType(triggerID, type: prev)

        case let .setVoice(triggerID, name: _):
            guard let prev = context.triggerVoice(triggerID: triggerID) else { return nil }
            return TriggerAction.setVoice(triggerID, name: prev)

        case let .setWordEnding(triggerID, wordEnding: _):
            guard let prev = context.triggerWordEnding(triggerID: triggerID) else { return nil }
            return TriggerAction.setWordEnding(triggerID, wordEnding: prev)

        case let .toggleCaseSensitive(triggerID):
            return TriggerAction.toggleCaseSensitive(triggerID)

        case let .toggleUseSubstitution(triggerID):
            return TriggerAction.toggleUseSubstitution(triggerID)

        }
    }
}
