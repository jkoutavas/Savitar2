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
            self.representedObject = MacroController(macro: macro, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class MacroController: NSController {
    var macro: Macro
    var store: ReactionsStore?

    @objc dynamic var name: String {
        get { macro.name }
        set(name) {
            store?.dispatch(MacroAction.rename(macro.objectID, name: name))
        }
    }

    @objc dynamic var keyLabel: String {
        get { macro.keyLabel }
        set(keyLabel) {
//            store?.dispatch(MacroAction.rename(macro.objectID, name: name))
        }
    }

    @objc dynamic var value: String {
        get { macro.value }
        set(value) {
            store?.dispatch(MacroAction.changeValue(macro.objectID, value: value))
        }
    }

    init(macro: Macro, store: ReactionsStore?) {
        self.macro = macro
        self.store = store

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
