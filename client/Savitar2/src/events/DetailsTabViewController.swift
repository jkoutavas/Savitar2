//
//  DetailsTabViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class DetailsTabViewController: NSTabViewController, ReactionStoreSetter {
    var store: ReactionsStore?

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        if let triggerViewController = tabView.tabViewItems[0].viewController as? TriggerViewController {
            triggerViewController.setStore(reactionsStore: store)
        }

        if let macroViewController = tabView.tabViewItems[1].viewController as? MacroViewController {
            macroViewController.setStore(reactionsStore: store)
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let triggerViewController = tabView.tabViewItems[0].viewController as? TriggerViewController {
            triggerViewController.setStore(reactionsStore: nil)
        }

        if let macroViewController = tabView.tabViewItems[1].viewController as? MacroViewController {
            macroViewController.setStore(reactionsStore: nil)
        }
    }
}
