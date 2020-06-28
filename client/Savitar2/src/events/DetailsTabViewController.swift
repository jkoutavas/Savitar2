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

        if let triggerView = tabView.tabViewItems[0].view as? TriggerView {
            triggerView.setStore(reactionsStore: store)
        }

        if let macroView = tabView.tabViewItems[1].view as? MacroView {
            macroView.setStore(reactionsStore: store)
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let triggerView = tabView.tabViewItems[0].view as? TriggerView {
            triggerView.setStore(reactionsStore: nil)
        }

        if let macroView = tabView.tabViewItems[1].view as? MacroView {
            macroView.setStore(reactionsStore: nil)
        }
    }
}
