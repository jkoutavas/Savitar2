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
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        if let triggerViewController = tabView.tabViewItems[0].viewController as? TriggerViewController {
            triggerViewController.setStore(store)
        }

        if let macroViewController = tabView.tabViewItems[1].viewController as? MacroViewController {
            macroViewController.setStore(store)
        }
    }
}
