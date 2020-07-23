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
    @IBOutlet var hotKeyEditor: HotKeyEditor!
    var macro: Macro?
    var store: ReactionsStore?

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
        hotKeyEditor.completionHandler = { (_ key: HotKey) in
            if key.isKnown() {
                if let _store = self.store, let _macro = self.macro {
                    _store.dispatch(MacroAction.changeKey(_macro.objectID, key: key))
                }
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    func newState(state: ReactionsState) {
        if let index = state.macroList.selection {
            let _macro = state.macroList.items[index]
            self.macro = _macro
            self.representedObject = MacroController(macro: _macro, store: store)
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

    @objc dynamic var keyLabel: String { return macro.keyLabel }

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
