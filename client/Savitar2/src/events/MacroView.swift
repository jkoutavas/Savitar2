//
//  MacroView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/28/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class MacroView: NSView, StoreSubscriber, ReactionStoreSetter {
    var store: ReactionsStore?

    @IBOutlet var name: NSTextField!

    func setStore(reactionsStore: ReactionsStore?) {
        if reactionsStore != nil {
            reactionsStore?.subscribe(self)
        } else {
            store?.unsubscribe(self)
        }
        store = reactionsStore
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
