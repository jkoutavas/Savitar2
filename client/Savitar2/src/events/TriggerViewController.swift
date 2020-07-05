//
//  TriggerViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerViewController: NSViewController, StoreSubscriber, ReactionStoreSetter {
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
            self.representedObject = TriggerController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class TriggerController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?

    @objc dynamic var name: String {
        get { trigger.name }
        set(name) {
            store?.dispatch(TriggerAction.rename(trigger.objectID, name: name))
        }
    }

    init(trigger: Trigger, store: ReactionsStore?) {
        self.trigger = trigger
        self.store = store

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
