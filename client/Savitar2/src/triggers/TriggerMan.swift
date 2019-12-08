//
//  TriggerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

class TriggerMan {
    private var triggers: [Trigger] = []

    func add(_ trigger: Trigger) {
        triggers.append(trigger)
    }

    func get() -> [Trigger] {
        return triggers
    }
}
