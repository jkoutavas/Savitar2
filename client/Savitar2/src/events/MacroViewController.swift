//
//  MacroViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/28/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class MacroViewController: NSViewController, StoreSubscriber, ReactionStoreSetter {
    var store: ReactionsStore?

    @IBOutlet var name: NSTextField!

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

    func newState(state: ReactionsState) {
        if let index = state.macroList.selection {
            let macro = state.macroList.items[index]
            name.stringValue = macro.name
        } else {
            name.stringValue = ""
        }
    }
}
