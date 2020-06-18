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
        type = "type" // TODO
        audioCue = "audioCue" // TODO
        super.init(identifier: trigger.objectID.identifier,
                   title: trigger.name,
                   enabled: !trigger.flags.contains(.disabled))
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
