//
//  TriggersViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct TriggersViewModel {
    let triggers: [TriggerViewModel]
    var itemCount: Int { return triggers.count }

    let selectedRow: Int?
    var selectedTrigger: TriggerViewModel? {
        guard let selectedRow = selectedRow else { return nil }
        return triggers[selectedRow]
    }
}
