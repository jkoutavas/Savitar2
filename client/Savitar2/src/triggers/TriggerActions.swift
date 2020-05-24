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

struct SetTriggerEnabledAction: ReactionAction {
    let identifier: String
    let enabled: Bool

    init(identifier: String, enabled: Bool) {
        self.identifier = identifier
        self.enabled = enabled
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        let triggers = oldState.triggerList.items
        for trigger in triggers where trigger.objectID.identifier == identifier {
            if enabled {
                trigger.flags.remove(.disabled) // TODO: hide this inversed crud
            } else {
                trigger.flags.insert(.disabled) // TODO: same goes for here
            }
        }
        var result = oldState
        result.triggerList.items = triggers
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
