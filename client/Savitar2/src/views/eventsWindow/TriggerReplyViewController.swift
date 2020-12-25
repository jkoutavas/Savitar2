//
//  TriggerReplyViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/18/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerReplyViewController: NSViewController, StoreSubscriber {
    var trigger: Trigger?

    var store: ReactionsStore?
    func setStore(_ store: ReactionsStore?) {
        self.store = store
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
        if let index = state.triggerList.selection, index < state.triggerList.items.count {
            let trigger = state.triggerList.items[index]
            self.trigger = trigger
            representedObject = TriggerReplyController(trigger: trigger, store: store)
        } else {
            representedObject = nil
        }
    }
}

class TriggerReplyController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?

    @objc dynamic var echoOutput: Bool {
        get { return trigger.echoReply }
        set {
            if trigger.echoReply != newValue {
                store?.dispatch(TriggerAction.toggleEchoOutput(trigger.objectID))
            }
        }
    }

    @objc dynamic var replyText: String {
        get { return trigger.reply ?? "" }
        set { store?.dispatch(TriggerAction.setReplyText(trigger.objectID, text: newValue)) }
    }

    @objc dynamic var storeIsPresent: Bool {
        return store != nil
    }

    init(trigger: Trigger, store: ReactionsStore?) {
        self.trigger = trigger
        self.store = store

        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
