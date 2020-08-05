//
//  TriggerAppearanceViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TriggerAppearanceViewController: NSViewController, TriggerEditor {

    var trigger: Trigger?
    func setTrigger(_ trigger: Trigger) {
        self.trigger = trigger
    }

    var store: ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }
}
