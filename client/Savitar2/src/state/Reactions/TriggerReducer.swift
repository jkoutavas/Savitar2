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
    case let .disable(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.enabled = false

    case let .enable(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.enabled = true

    case let .rename(triggerID, name: name):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.name = name

    case let .setAppearance(triggerID, type: appearance):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.appearance = appearance

    case let .setAudioType(triggerID, type: audioType):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.audioType = audioType

    case let .setBackColor(triggerID, color: color):
        guard trigger.objectID == triggerID else { return trigger }
        if trigger.style == nil, color != nil {
            trigger.style = TrigTextStyle()
        }
        trigger.style?.backColor = color
        trigger.style?.formOnOff()

    case let .setFace(triggerID, face: face):
        guard trigger.objectID == triggerID else { return trigger }
        if trigger.style == nil, face != nil {
            trigger.style = TrigTextStyle()
        }
        trigger.style?.face = face
        trigger.style?.formOnOff()

    case let .setForeColor(triggerID, color: color):
        guard trigger.objectID == triggerID else { return trigger }
        if trigger.style == nil, color != nil {
            trigger.style = TrigTextStyle()
        }
        trigger.style?.foreColor = color
        trigger.style?.formOnOff()

    case let .setMatching(triggerID, matching: matching):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.matching = matching

    case let .setReplyText(triggerID, text: text):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.reply = text

    case let .setSayText(triggerID, text: text):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.say = text

    case let .setSound(triggerID, name: name):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.sound = name

    case let .setSpecifier(triggerID, specifier: specifier):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.specifier = specifier

    case let .setSubstitution(triggerID, substitution: substitution):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.substitution = substitution

    case let .setType(triggerID, type: type):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.type = type
        if type == .input {
            trigger.appearance = .gag
        }

    case let .setVoice(triggerID, name: name):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.voice = name

    case let .setWordEnding(triggerID, wordEnding: wordEnding):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.wordEnding = wordEnding

    case let .toggleCaseSensitive(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.caseSensitive = !trigger.caseSensitive

    case let .toggleEchoOutput(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.echoReply = !trigger.echoReply

    case let .toggleUseSubstitution(triggerID):
        guard trigger.objectID == triggerID else { return trigger }
        trigger.useSubstitution = !trigger.useSubstitution
    }

    return trigger
}
