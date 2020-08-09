//
//  TriggerActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/17/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
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
    case setMatching(SavitarObjectID, matching: TriggerMatching)
    case setSubstitution(SavitarObjectID, substitution: String)
    case setType(SavitarObjectID, type: TrigType)
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
        case .setMatching: return "Change Trigger Matching"
        case .setSubstitution: return "Change Trigger Substitution"
        case .setType: return "Change Trigger Type"
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

        case let .setMatching(triggerID, matching: _):
            guard let prev = context.triggerMatching(triggerID: triggerID) else { return nil }
            return TriggerAction.setMatching(triggerID, matching: prev)

        case let .setSubstitution(triggerID, substitution: _):
            guard let prev = context.triggerSubstitution(triggerID: triggerID) else { return nil }
            return TriggerAction.setSubstitution(triggerID, substitution: prev)

        case let .setType(triggerID, type: _):
            guard let prev = context.triggerType(triggerID: triggerID) else { return nil }
            return TriggerAction.setType(triggerID, type: prev)

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
