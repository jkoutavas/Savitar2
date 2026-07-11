//
//  DetailsTabViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/21/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class DetailsTabViewController: NSTabViewController, ReactionsStoreSetter {
    var store: ReactionsStore?

    func setStore(_ store: ReactionsStore?) {
        self.store = store
        propagateStoreToTabs()
    }

    override func viewWillAppear() {
        propagateStoreToTabs()
        super.viewWillAppear()
    }

    private func propagateStoreToTabs() {
        if let triggerViewController = tabViewItems[0].viewController as? TriggerViewController {
            triggerViewController.setStore(store)
        }

        if tabViewItems.count > 1,
           let macroViewController = tabViewItems[1].viewController as? MacroViewController {
            macroViewController.setStore(store)
        }
    }
}
