//
//  TriggerMatchingViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerMatchingViewController: NSViewController, StoreSubscriber {
    @IBOutlet var matchExactlyRadio: NSButton!
    @IBOutlet var matchWholeLineRadio: NSButton!
    @IBOutlet var matchWholeWordRadio: NSButton!

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

    @IBAction func matchingRadioButtonChanged(_ sender: AnyObject) {
        guard let trigger = self.trigger else { return }

        if matchExactlyRadio.state == .on {
            store?.dispatch(TriggerAction.setMatching(trigger.objectID, matching: .exact))
        } else if matchWholeLineRadio.state == .on {
            store?.dispatch(TriggerAction.setMatching(trigger.objectID, matching: .wholeLine))
        } else {
            store?.dispatch(TriggerAction.setMatching(trigger.objectID, matching: .wholeWord))
        }
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection {
            let trigger = state.triggerList.items[index]
            self.trigger = trigger
            switch trigger.matching {
            case .exact:
                matchExactlyRadio.state = .on
            case .wholeLine:
                matchWholeLineRadio.state = .on
            case .wholeWord:
                matchWholeWordRadio.state = .on
            }
            self.representedObject = TriggerMatchingController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class TriggerMatchingController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?

    @objc dynamic var storeIsPresent: Bool {
        return store != nil
    }

    @objc dynamic var substitution: String {
        get { return trigger.substitution ?? "" }
        set {
            store?.dispatch(TriggerAction.setSubstitution(trigger.objectID, substitution: newValue))
        }
    }

    @objc dynamic var useSubstitution: Bool {
        get { return trigger.useSubstitution }
        set {
            if trigger.useSubstitution != newValue {
                store?.dispatch(TriggerAction.toggleUseSubstitution(trigger.objectID))
            }
        }
    }

    @objc dynamic var useWordEnding: Bool {
        return trigger.matching == .wholeWord
    }

    @objc dynamic var wordEnding: String {
        get { return trigger.wordEnding ?? "" }
        set {
            store?.dispatch(TriggerAction.setWordEnding(trigger.objectID, wordEnding: newValue))
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
