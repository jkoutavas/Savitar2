//
//  TriggerMatchingViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TriggerMatchingViewController: NSViewController, TriggerEditor {

    @IBOutlet var matchExactlyRadio: NSButton!
    @IBOutlet var matchWholeLineRadio: NSButton!
    @IBOutlet var matchWholeWordRadio: NSButton!

    @IBAction func matchingRadioButtonChanged(_ sender: AnyObject) {
    }

    var trigger: Trigger?
    func setTrigger(_ trigger: Trigger) {
        self.trigger = trigger
        if trigger.flags.contains(.exact) {
            matchExactlyRadio.state = .on
        } else if trigger.flags.contains(.wholeLine) {
            matchWholeLineRadio.state = .on
        } else if trigger.flags.contains(.toEndOfWord) {
            matchWholeWordRadio.state = .on
        }
    }

    var store: ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }
}
