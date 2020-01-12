//
//  TriggerController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/10/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TriggerController: NSController {
    var trigger: Trigger

    // TODO: is there a more elegant way of representing this?
    @objc dynamic var name: String { get { trigger.name } set(name) { trigger.name = name } }

    init(trigger: Trigger) {
        self.trigger = trigger

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
