//
//  TriggerReducer.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/25/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import ReSwift

func triggerReducer(_ action: Action, state: Trigger?) -> Trigger? {

    guard let action = action as? TriggerAction,
        let trigger = state
        else { return state }

    return handleTriggerAction(action, trigger: trigger)
}

private func handleTriggerAction(_ action: TriggerAction, trigger: Trigger) -> Trigger {

    let trigger = trigger

    switch action {
    case let .enable(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.flags.remove(.disabled) // TODO: hide this inversed crud

    case let .disable(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.flags.insert(.disabled) // TODO: same goes for here

    case let .rename(triggerID, name: name):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.name = name
    }

    return trigger
}