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
        trigger.enabled = true

    case let .disable(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.enabled = false

    case let .rename(triggerID, name: name):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.name = name

    case let .setMatching(triggerID, matching: matching):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.matching = matching

    case let .setSpecifier(triggerID, specifier: specifier):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.specifier = specifier

    case let .setSubstitution(triggerID, substitution: substitution):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.substitution = substitution

    case let .setType(triggerID, type: type):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.type = type

    case let .setWordEnding(triggerID, wordEnding: wordEnding):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.wordEnding = wordEnding

    case let .toggleCaseSensitive(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.caseSensitive = !trigger.caseSensitive

    case let .toggleUseSubstitution(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.useSubstitution = !trigger.useSubstitution
    }

    return trigger
}
