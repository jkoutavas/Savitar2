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
    private var nameField: NSTextField!
    private var hotKeyField: HotKeyField!
    private var valueField: NSTextField!

    var macro: Macro?
    var macros: [Macro]?
    var store: ReactionsStore?

    func setStore(_ store: ReactionsStore?) {
        self.store = store
        if isViewLoaded {
            refreshFromStore()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildForm()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
        refreshFromStore()

        hotKeyField.completionHandler = { [weak self] key in
            guard let self else { return }
            if key != self.macro?.hotKey, key.isKnown() {
                let keyString = key.toString()
                if AppContext.shared.reservedKeyList.contains(where: { $0 == keyString }) {
                    self.displayError(msg: "'\(keyString)' is a reserved key.")
                } else if let macros = self.macros, macros.contains(where: { $0.hotKey == key }) {
                    self.displayError(msg: "Hotkey '\(keyString)' is already in use")
                } else if let store = self.store, let macroID = self.macro?.objectID {
                    store.dispatch(MacroAction.changeKey(macroID, key: key))
                }
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    func newState(state: ReactionsState) {
        macros = state.macroList.items
        if let index = state.macroList.selection, index < state.macroList.items.count {
            let macro = state.macroList.items[index]
            self.macro = macro
            representedObject = MacroController(macro: macro, store: store)
            syncDetailFields(macro: macro)
        } else {
            representedObject = nil
            macro = nil
            syncDetailFields(macro: nil)
        }
        updateBindings()
    }

    private func refreshFromStore() {
        guard let store else {
            representedObject = nil
            macro = nil
            syncDetailFields(macro: nil)
            updateBindings()
            return
        }
        newState(state: store.state)
    }

    private func buildForm() {
        let margin: CGFloat = 20
        let rowSpacing: CGFloat = 8
        let labelWidth: CGFloat = 52
        let fieldHeight: CGFloat = 24

        func makeLabel(_ title: String) -> NSTextField {
            let label = NSTextField(labelWithString: title)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alignment = .right
            return label
        }

        let nameLabel = makeLabel("Name:")
        let hotkeyLabel = makeLabel("Hotkey:")
        let valueLabel = makeLabel("Value:")

        nameField = NSTextField()
        hotKeyField = HotKeyField()
        valueField = NSTextField()

        nameField.translatesAutoresizingMaskIntoConstraints = false
        hotKeyField.translatesAutoresizingMaskIntoConstraints = false
        valueField.translatesAutoresizingMaskIntoConstraints = false
        nameField.applySavitarFormFieldStyle()
        hotKeyField.applySavitarFormFieldStyle()
        valueField.applySavitarFormFieldStyle()

        nameField.usesSingleLineMode = true
        hotKeyField.isEditable = false
        hotKeyField.isSelectable = true
        valueField.isEditable = true
        valueField.usesSingleLineMode = false
        valueField.cell?.wraps = true
        valueField.cell?.isScrollable = true

        view.addSubview(nameLabel)
        view.addSubview(hotkeyLabel)
        view.addSubview(valueLabel)
        view.addSubview(nameField)
        view.addSubview(hotKeyField)
        view.addSubview(valueField)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            nameLabel.widthAnchor.constraint(equalToConstant: labelWidth),
            hotkeyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            hotkeyLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            valueLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),

            nameField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            nameField.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            nameField.heightAnchor.constraint(equalToConstant: fieldHeight),
            nameLabel.centerYAnchor.constraint(equalTo: nameField.centerYAnchor),

            hotKeyField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            hotKeyField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            hotKeyField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: rowSpacing),
            hotKeyField.heightAnchor.constraint(equalToConstant: fieldHeight),
            hotkeyLabel.centerYAnchor.constraint(equalTo: hotKeyField.centerYAnchor),

            valueField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            valueField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            valueField.topAnchor.constraint(equalTo: hotKeyField.bottomAnchor, constant: rowSpacing + 2),
            valueField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin),
            valueField.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            valueLabel.topAnchor.constraint(equalTo: valueField.topAnchor, constant: 2)
        ])
    }

    private func updateBindings() {
        nameField.unbind(.value)
        nameField.unbind(.enabled)
        nameField.unbind(.editable)
        valueField.unbind(.value)
        valueField.unbind(.enabled)
        valueField.unbind(.editable)
        hotKeyField.unbind(.enabled)

        guard representedObject != nil else { return }

        let bindingOptions: [NSBindingOption: Any] = [.continuouslyUpdatesValue: true]
        nameField.bind(.value, to: self, withKeyPath: "representedObject.name", options: bindingOptions)
        nameField.bind(.enabled, to: self, withKeyPath: "representedObject.storeIsPresent")
        nameField.bind(.editable, to: self, withKeyPath: "representedObject.storeIsPresent")
        valueField.bind(.value, to: self, withKeyPath: "representedObject.value", options: bindingOptions)
        valueField.bind(.enabled, to: self, withKeyPath: "representedObject.storeIsPresent")
        valueField.bind(.editable, to: self, withKeyPath: "representedObject.storeIsPresent")
        hotKeyField.bind(.enabled, to: self, withKeyPath: "representedObject.storeIsPresent")
    }

    private func syncDetailFields(macro: Macro?) {
        guard isViewLoaded else { return }
        nameField.stringValue = macro?.name ?? ""
        valueField.stringValue = macro?.value ?? ""
        hotKeyField.stringValue = macro?.keyLabel ?? ""
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
