//
//  TriggerAppearanceViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerAppearanceViewController: NSViewController, StoreSubscriber {

    @IBOutlet var gagRadio: NSButton!
    @IBOutlet var dontAlterRadio: NSButton!
    @IBOutlet var changeRadio: NSButton!

    var trigger: Trigger?

    var store: ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection {
            let trigger = state.triggerList.items[index]
            self.trigger = trigger
            /*
             if trigger.matchesExact {
             matchExactlyRadio.state = .on
             } else if trigger.matchesWholeLine {
             matchWholeLineRadio.state = .on
             } else if trigger.matchesWholeWord {
             matchWholeWordRadio.state = .on
             }
             */
            self.representedObject = TriggerMatchingController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}
