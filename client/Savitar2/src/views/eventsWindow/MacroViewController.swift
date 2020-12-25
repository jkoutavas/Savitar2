//
//  MacroViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/28/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class MacroViewController: NSViewController, StoreSubscriber, ReactionsStoreSetter {
    @IBOutlet weak var hotKeyEditor: HotKeyEditor!
    var macro: Macro?
    var macros: [Macro]?
    var store: ReactionsStore?

    func setStore(_ store: ReactionsStore?) {
        self.store = store
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
        hotKeyEditor.completionHandler = { (_ key: HotKey) in
            if key != self.macro?.hotKey && key.isKnown() {
                let keyString = key.toString()
                if AppContext.shared.reservedKeyList.contains(where: {$0 == keyString}) {
                    self.displayError(msg: "'\(keyString)' is a reserved key.")
                } else if let _macros = self.macros, _macros.contains(where: {$0.hotKey == key}) {
                    self.displayError(msg: "Hotkey '\(keyString)' is already in use")
                } else {
                    if let _store = self.store, let _macroID = self.macro?.objectID {
                        _store.dispatch(MacroAction.changeKey(_macroID, key: key))
                    }
                }
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    func newState(state: ReactionsState) {
        self.macros = state.macroList.items
        if let index = state.macroList.selection, index < state.macroList.items.count {
            let macro = state.macroList.items[index]
            self.macro = macro
            self.representedObject = MacroController(macro: macro, store: store)
        } else {
            self.representedObject = nil
            self.macro = nil
        }
    }

    func displayError(msg: String) {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = "Please try another hotkey"
        alert.addButton(withTitle: "OK")
        alert.alertStyle = NSAlert.Style.warning
        alert.runModal()
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

    @objc dynamic var storeIsPresent: Bool {
        return store != nil
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
