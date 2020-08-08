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

    var trigger: Trigger?
    func setTrigger(_ trigger: Trigger) {
        self.trigger = trigger
        if trigger.matchesExact {
            matchExactlyRadio.state = .on
        } else if trigger.matchesWholeLine {
            matchWholeLineRadio.state = .on
        } else if trigger.matchesWholeWord {
            matchWholeWordRadio.state = .on
        }
    }

    var store: ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    @IBAction func matchingRadioButtonChanged(_ sender: AnyObject) {
        guard let trig = trigger else { return }

        if matchExactlyRadio.state == .on {
            store?.dispatch(TriggerAction.setMatching(trig.objectID, matching: .exact))
        } else if matchWholeLineRadio.state == .on {
            store?.dispatch(TriggerAction.setMatching(trig.objectID, matching: .wholeLine))
        } else {
            store?.dispatch(TriggerAction.setMatching(trig.objectID, matching: .wholeWord))
        }
    }
}
