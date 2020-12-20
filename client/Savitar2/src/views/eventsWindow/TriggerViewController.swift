//
//  TriggerViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerViewController: NSViewController, StoreSubscriber, ReactionsStoreSetter {
    var appearanceViewController: TriggerAppearanceViewController?
    var audioCueViewController: TriggerAudioCueViewController?
    var matchingViewController: TriggerMatchingViewController?
    var replyViewController: TriggerReplyViewController?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Go off and find the view controllers for each tab
        if segue.destinationController is NSTabViewController {
            if let tabViewController = segue.destinationController as? NSTabViewController {
                for tabViewItem in tabViewController.tabViewItems {
                    if let tabVC = tabViewItem.viewController as? TriggerAppearanceViewController {
                        appearanceViewController = tabVC
                    } else if let tabVC = tabViewItem.viewController as? TriggerAudioCueViewController {
                        audioCueViewController = tabVC
                    } else if let tabVC = tabViewItem.viewController as? TriggerMatchingViewController {
                        matchingViewController = tabVC
                    } else if let tabVC = tabViewItem.viewController as? TriggerReplyViewController {
                        replyViewController = tabVC
                    }
                }
            }
        }
    }

    var store: ReactionsStore?

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
        appearanceViewController?.setStore(reactionsStore: store)
        audioCueViewController?.setStore(reactionsStore: store)
        matchingViewController?.setStore(reactionsStore: store)
        replyViewController?.setStore(reactionsStore: store)
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
            self.representedObject = TriggerController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class TriggerController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?

    @objc dynamic var activated: Bool {
        get { trigger.enabled }
        set {
            if newValue {
                store?.dispatch(TriggerAction.enable(trigger.objectID))
            } else {
                store?.dispatch(TriggerAction.disable(trigger.objectID))
            }
        }
    }

    @objc dynamic var caseSensitive: Bool {
        get { trigger.caseSensitive }
        set {
            if trigger.caseSensitive != newValue {
                store?.dispatch(TriggerAction.toggleCaseSensitive(trigger.objectID))
            }
        }
    }

    @objc dynamic var name: String {
        get { trigger.name }
        set {
            store?.dispatch(TriggerAction.rename(trigger.objectID, name: newValue))
        }
    }

    @objc dynamic var specifierIndex: Int {
        get {
            switch trigger.specifier {
            case .startsWith:
                return 0
            case .lineContains:
                return 1
            case .useRegex:
                return 2
            }
        }
        set {
            var specifier: TrigSpecifier
            switch newValue {
            case 0:
                specifier = .startsWith
            case 1:
                specifier = .lineContains
            case 2:
                specifier = .useRegex
            default:
                specifier = .startsWith
            }
            store?.dispatch(TriggerAction.setSpecifier(trigger.objectID, specifier: specifier))
        }
    }

    @objc dynamic var storeIsPresent: Bool {
        return store != nil
    }

    @objc dynamic var typeIndex: Int {
        get {
            switch trigger.type {
            case .output:
                return 0
            case .input:
                return 1
            case .both:
                return 2
            }
        }
        set {
            var type: TrigType
            switch newValue {
            case 0:
                type = .output
            case 1:
                type = .input
            case 2:
                type = .both
            default:
                type = .output
            }
            store?.dispatch(TriggerAction.setType(trigger.objectID, type: type))
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
