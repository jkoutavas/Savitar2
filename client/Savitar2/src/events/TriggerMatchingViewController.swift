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
            if trigger.matchesExact {
                matchExactlyRadio.state = .on
            } else if trigger.matchesWholeLine {
                matchWholeLineRadio.state = .on
            } else if trigger.matchesWholeWord {
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

    @objc dynamic var substitution: String {
        get {
            return trigger.substitution ?? ""
        }
        set(substitution) {
            store?.dispatch(TriggerAction.setSubstitution(trigger.objectID, substitution: substitution))
        }
    }

    @objc dynamic var useSubstitution: Bool {
        get {
            return trigger.useSubstitution
        }
        set(useSubstitution) {
            if trigger.useSubstitution != useSubstitution {
                store?.dispatch(TriggerAction.toggleUseSubstitution(trigger.objectID))
            }
        }
    }

    @objc dynamic var useWordEnding: Bool {
        get {
            return trigger.matchesWholeWord
        }
    }

    @objc dynamic var wordEnding: String {
        get {
            return trigger.wordEnding ?? ""
        }
        set(wordEnding) {
             store?.dispatch(TriggerAction.setWordEnding(trigger.objectID, wordEnding: wordEnding))
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
