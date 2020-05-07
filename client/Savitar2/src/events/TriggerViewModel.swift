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

struct TriggerViewModel: Codable {
    let identifier: String

    let name: String
    let type: String
    let audioCue: String
    
    init(trigger: Trigger) {
        identifier = trigger.objectID.identifier
        name = trigger.name
        type = "type" // TODO
        audioCue = "audioCue" // TODO
    }
}
