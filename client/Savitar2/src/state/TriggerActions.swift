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
    case enable(SavitarObjectID)
    case disable(SavitarObjectID)
    case rename(SavitarObjectID, name: String)
    case toggleCaseSensitive(SavitarObjectID, sensitive: Bool)

    // MARK: Undoable

    var isUndoable: Bool { return true }

    var name: String {
        switch self {
        case .enable: return "Enable Trigger"
        case .disable: return "Disable Trigger"
        case .rename: return "Rename Trigger"
        case .toggleCaseSensitive: return "Change Case Sensitive"
        }
    }

    func inverse(context: UndoActionContext) -> UndoableAction? {
        switch self {
        case .enable(let triggerID):
            return TriggerAction.disable(triggerID)
        case .disable(let triggerID):
            return TriggerAction.enable(triggerID)
        case .rename(let triggerID, name: _):
            guard let oldName = context.triggerName(triggerID: triggerID) else { return nil }
            return TriggerAction.rename(triggerID, name: oldName)
        case .toggleCaseSensitive(let triggerID, let sensitive):
            return TriggerAction.toggleCaseSensitive(triggerID, sensitive: !sensitive)
        }
    }
}
