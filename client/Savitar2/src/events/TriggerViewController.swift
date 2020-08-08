//
//  TriggerViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

protocol TriggerEditor: ReactionStoreSetter {
    func setTrigger(_ trigger: Trigger)
}

class TriggerViewController: NSViewController, StoreSubscriber, ReactionStoreSetter {
    var appearanceViewController: TriggerAppearanceViewController?
    var matchingViewController: TriggerMatchingViewController?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Go off and find the view controllers for each tab
        if segue.destinationController is NSTabViewController {
            if let tabViewController = segue.destinationController as? NSTabViewController {
                for tabViewItem in tabViewController.tabViewItems {
                    if let tabVC = tabViewItem.viewController as? TriggerAppearanceViewController {
                        appearanceViewController = tabVC
                    } else if let tabVC = tabViewItem.viewController as? TriggerMatchingViewController {
                        matchingViewController = tabVC
                    }
                }
            }
        }
    }

    var store: ReactionsStore?

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
        appearanceViewController?.setStore(reactionsStore: store)
        matchingViewController?.setStore(reactionsStore: store)
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
            appearanceViewController?.setTrigger(trigger)
            matchingViewController?.setTrigger(trigger)
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

    @objc dynamic var activated: Bool {
        get { trigger.enabled }
        set(activated) {
            if activated {
                store?.dispatch(TriggerAction.enable(trigger.objectID))
            } else {
                store?.dispatch(TriggerAction.disable(trigger.objectID))
            }
        }
    }

    @objc dynamic var caseSensitive: Bool {
        get { trigger.caseSensitive }
        set(caseSensitive) {
            store?.dispatch(TriggerAction.toggleCaseSensitive(trigger.objectID, sensitive: caseSensitive))
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
