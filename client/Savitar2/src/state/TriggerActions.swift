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
    case setBackColor(SavitarObjectID, color: NSColor?)
    case setFace(SavitarObjectID, face: TrigFace?)
    case setForeColor(SavitarObjectID, color: NSColor?)
    case setMatching(SavitarObjectID, matching: TrigMatching)
    case setReplyText(SavitarObjectID, text: String?)
    case setSayText(SavitarObjectID, text: String?)
    case setSound(SavitarObjectID, name: String?)
    case setSpecifier(SavitarObjectID, specifier: TrigSpecifier)
    case setSubstitution(SavitarObjectID, substitution: String?)
    case setType(SavitarObjectID, type: TrigType)
    case setVoice(SavitarObjectID, name: String?)
    case setWordEnding(SavitarObjectID, wordEnding: String?)
    case toggleCaseSensitive(SavitarObjectID)
    case toggleEchoOutput(SavitarObjectID)
    case toggleUseSubstitution(SavitarObjectID)

    // MARK: Undoable

    var isUndoable: Bool { return true }

    var name: String {
        switch self {
        case .disable: return "Disable Trigger"
        case .enable: return "Enable Trigger"
        case .rename: return "Rename Trigger"
        case .setAppearance: return "Change Trigger Appearance Type"
        case .setAudioType: return "Change Trigger Audio Type"
        case .setBackColor: return "Change Trigger Back Color"
        case .setFace: return "Change Trigger Face"
        case .setForeColor: return "Change Trigger Fore Color"
        case .setMatching: return "Change Trigger Matching"
        case .setReplyText: return "Change Trigger Reply"
        case .setSayText: return "Change Trigger Spoken Text"
        case .setSound: return "Change Trigger Sound"
        case .setSpecifier: return "Change Trigger Specifier"
        case .setSubstitution: return "Change Trigger Substitution"
        case .setType: return "Change Trigger Type"
        case .setVoice: return "Change Trigger Voice"
        case .setWordEnding: return "Change Trigger Word Ending"
        case .toggleCaseSensitive: return "Change Trigger Case Sensitive"
        case .toggleEchoOutput: return "Change Trigger Echo to Output"
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
            return TriggerAction.rename(triggerID, name:
                context.triggerName(triggerID: triggerID) ?? "")

        case let .setAppearance(triggerID, type: _):
            return TriggerAction.setAppearance(triggerID, type:
                context.triggerAppearance(triggerID: triggerID) ?? TrigAppearance())

        case let .setAudioType(triggerID, type: _):
            return TriggerAction.setAudioType(triggerID, type:
                context.triggerAudioType(triggerID: triggerID) ?? TrigAudioType())

        case let .setBackColor(triggerID, color: _):
            return TriggerAction.setBackColor(triggerID, color:
                context.triggerBackColor(triggerID: triggerID) ?? nil)

        case let .setFace(triggerID, face: _):
            return TriggerAction.setFace(triggerID, face: context.triggerFace(triggerID: triggerID))

        case let .setForeColor(triggerID, color: _):
            return TriggerAction.setForeColor(triggerID, color:
                 context.triggerForeColor(triggerID: triggerID) ?? nil)

        case let .setMatching(triggerID, matching: _):
            return TriggerAction.setMatching(triggerID, matching:
                context.triggerMatching(triggerID: triggerID) ?? TrigMatching())

        case let .setReplyText(triggerID, text: _):
            return TriggerAction.setReplyText(triggerID, text: context.triggerReplyText(triggerID: triggerID))

        case let .setSayText(triggerID, text: _):
            return TriggerAction.setSayText(triggerID, text: context.triggerSayText(triggerID: triggerID))

        case let .setSound(triggerID, name: _):
            return TriggerAction.setSound(triggerID, name: context.triggerSound(triggerID: triggerID))

        case let .setSpecifier(triggerID, specifier: _):
            return TriggerAction.setSpecifier(triggerID, specifier:
                context.triggerSpecifier(triggerID: triggerID) ?? TrigSpecifier())

        case let .setSubstitution(triggerID, substitution: _):
            return TriggerAction.setSubstitution(triggerID, substitution:
                context.triggerSubstitution(triggerID: triggerID))

        case let .setType(triggerID, type: _):
            return TriggerAction.setType(triggerID, type: context.triggerType(triggerID: triggerID) ?? TrigType())

        case let .setVoice(triggerID, name: _):
            return TriggerAction.setVoice(triggerID, name: context.triggerVoice(triggerID: triggerID))

        case let .setWordEnding(triggerID, wordEnding: _):
            return TriggerAction.setWordEnding(triggerID, wordEnding: context.triggerWordEnding(triggerID: triggerID))

        case let .toggleCaseSensitive(triggerID):
            return TriggerAction.toggleCaseSensitive(triggerID)

        case let .toggleEchoOutput(triggerID):
            return TriggerAction.toggleEchoOutput(triggerID)

        case let .toggleUseSubstitution(triggerID):
            return TriggerAction.toggleUseSubstitution(triggerID)
        }
    }
}
