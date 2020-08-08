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
    @IBOutlet var endOfWordPrompt: NSTextField!
    @IBOutlet var endOfWordEdit: NSTextField!

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

    @objc dynamic var wordEnding: String {
        get {
            guard let trig = self.trigger, let wordEnding = trig.wordEnding else { return "" }
            return wordEnding
        }
        set(wordEnding) {
            guard let trig = self.trigger else { return }
            store?.dispatch(TriggerAction.setWordEnding(trig.objectID, wordEnding: wordEnding))
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
            endOfWordPrompt.textColor = trigger.matchesWholeWord ? NSColor.black : NSColor.gray
            endOfWordEdit.isEnabled = trigger.matchesWholeWord
            if let wordEnding = trigger.wordEnding {
                endOfWordEdit.stringValue = wordEnding
            } else {
                endOfWordEdit.stringValue = ""
            }
        }
    }
}
