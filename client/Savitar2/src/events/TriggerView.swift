//
//  TriggerView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerView: NSView, StoreSubscriber, ReactionStoreSetter {
    var store: ReactionsStore?

    @IBOutlet var name: NSTextField!

    func setStore(reactionsStore: ReactionsStore?) {
        if reactionsStore != nil {
            reactionsStore?.subscribe(self)
        } else {
            store?.unsubscribe(self)
        }
        store = reactionsStore
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection {
            let trigger = state.triggerList.items[index]
            name.stringValue = trigger.name
        } else {
            name.stringValue = ""
        }
    }
}
