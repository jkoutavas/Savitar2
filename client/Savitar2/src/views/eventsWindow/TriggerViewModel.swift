//
//  TriggerViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

protocol DisplaysTrigger {
    func showTrigger(triggerViewModel viewModel: TriggerViewModel)
}

class TriggerViewModel: CheckableItemViewModel {
    let type: String
    let audioCue: String

    init(trigger: Trigger) {
        switch trigger.type {
        case .input:
            type = "Input"
        case .output:
            type = "Output"
        case .both:
            type = "Both"
        }
        switch trigger.audioType {
        case .silent:
            audioCue = "silent"
        case .sound:
            audioCue = trigger.sound ?? ""
        case .speakEvent, .sayText:
            audioCue = "spoken"
        }
        super.init(itemID: trigger.objectID.identifier,
                   title: trigger.name,
                   enabled: trigger.enabled)
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
