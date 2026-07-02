//
//  AppPrefsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/5/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class AppPrefsViewController: NSViewController, StoreSubscriber {
    var store: AppPreferencesStore?

    private var checkboxBindings: [(button: NSButton, keyPath: String, supported: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        buildPreferencesUI()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        store?.subscribe(self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        store?.unsubscribe(self)
    }

    func newState(state _: AppPreferencesState) {
        unbindCheckboxes()
        representedObject = AppPrefsPresenter(store: store!)
        bindCheckboxes()
    }

    private func buildPreferencesUI() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12

        stack.addArrangedSubview(section(
            title: "Startup",
            items: [
                .enabled("showStartupPicker", title: "Show World Picker at startup"),
                .disabled("showStartupClicker", title: "Show Macro Clicker at startup",
                           toolTip: "Available when the Macro Clicker window ships."),
                .enabled("showEventsWindowAtStartup", title: "Show Events Window at startup")
            ]
        ))

        stack.addArrangedSubview(section(
            title: "Input & Display",
            items: [
                .enabled("useKeypad", title: "Use keypad for macro entry"),
                .enabled("monoFontsOnly", title: "Mono fonts only (in font menus)"),
                .disabled("defaultWordWrap", title: "Default word wrap for new sessions",
                          toolTip: "Word wrap for new sessions is not yet implemented.")
            ]
        ))

        stack.addArrangedSubview(section(
            title: "Audio (session cues)",
            items: [
                .enabled("muteSound", title: "Mute sound cues"),
                .enabled("muteSpeaking", title: "Mute speaking cues"),
                .disabled("muteClicker", title: "Mute clicker sounds",
                          toolTip: "Available when the Macro Clicker ships."),
                .enabled("muteBell", title: "Mute terminal bell")
            ]
        ))

        stack.addArrangedSubview(section(
            title: "Updates",
            items: [
                .disabled("updatingEnabled", title: "Check for updates automatically",
                          toolTip: "Available when in-app update checking ships.")
            ]
        ))

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let window = view.window else { return }
        view.layoutSubtreeIfNeeded()
        let fittingSize = view.fittingSize
        window.setContentSize(NSSize(width: max(420, fittingSize.width + 40),
                                     height: fittingSize.height + 40))
    }

    private enum CheckboxItem {
        case enabled(String, title: String)
        case disabled(String, title: String, toolTip: String)
    }

    private func section(title: String, items: [CheckboxItem]) -> NSView {
        let box = NSBox()
        box.title = title
        box.boxType = .primary
        box.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        for item in items {
            let checkbox = NSButton(checkboxWithTitle: checkboxTitle(item), target: nil, action: nil)
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            switch item {
            case let .enabled(keyPath, _):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                checkboxBindings.append((checkbox, keyPath, true))
            case let .disabled(keyPath, _, toolTip):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                styleUnsupportedCheckbox(checkbox, toolTip: toolTip)
                checkboxBindings.append((checkbox, keyPath, false))
            }
            stack.addArrangedSubview(checkbox)
        }

        box.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 18),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12)
        ])

        return box
    }

    private func checkboxTitle(_ item: CheckboxItem) -> String {
        switch item {
        case let .enabled(_, title):
            return title
        case let .disabled(_, title, _):
            return title
        }
    }

    private func styleUnsupportedCheckbox(_ checkbox: NSButton, toolTip: String) {
        checkbox.isEnabled = false
        checkbox.toolTip = toolTip
        if #available(macOS 10.14, *) {
            checkbox.contentTintColor = .secondaryLabelColor
        }
    }

    private func bindCheckboxes() {
        guard let presenter = representedObject as? AppPrefsPresenter else { return }
        let bindOptions: [NSBindingOption: Any] = [.conditionallySetsEnabled: false]
        for entry in checkboxBindings {
            if entry.supported {
                entry.button.bind(.value, to: presenter, withKeyPath: entry.keyPath, options: bindOptions)
            } else if let value = presenter.value(forKeyPath: entry.keyPath) as? Bool {
                entry.button.state = value ? .on : .off
                styleUnsupportedCheckbox(entry.button, toolTip: entry.button.toolTip ?? "")
            }
        }
    }

    private func unbindCheckboxes() {
        for entry in checkboxBindings {
            if entry.supported {
                entry.button.unbind(.value)
            }
        }
    }
}

class AppPrefsPresenter: NSObject {
    private var store: AppPreferencesStore

    init(store: AppPreferencesStore) {
        self.store = store
        super.init()
    }

    @objc dynamic var showStartupPicker: Bool {
        get { flag(.startupPicker) }
        set { store.dispatch(SetShowStartupPickerAction(newValue)) }
    }

    @objc dynamic var showStartupClicker: Bool {
        get { flag(.startupClicker) }
        set { store.dispatch(SetPrefsFlagAction(flag: .startupClicker, enabled: newValue)) }
    }

    @objc dynamic var showEventsWindowAtStartup: Bool {
        get { flag(.startupEventsWindow) }
        set { store.dispatch(SetShowEventsWindowAtStartupAction(newValue)) }
    }

    @objc dynamic var useKeypad: Bool {
        get { flag(.useKeypad) }
        set { store.dispatch(SetPrefsFlagAction(flag: .useKeypad, enabled: newValue)) }
    }

    @objc dynamic var monoFontsOnly: Bool {
        get { flag(.monoFontsOnly) }
        set { store.dispatch(SetPrefsFlagAction(flag: .monoFontsOnly, enabled: newValue)) }
    }

    @objc dynamic var defaultWordWrap: Bool {
        get { flag(.defaultWordWrap) }
        set { store.dispatch(SetPrefsFlagAction(flag: .defaultWordWrap, enabled: newValue)) }
    }

    @objc dynamic var muteSound: Bool {
        get { flag(.muteSound) }
        set { store.dispatch(SetPrefsFlagAction(flag: .muteSound, enabled: newValue)) }
    }

    @objc dynamic var muteSpeaking: Bool {
        get { flag(.muteSpeaking) }
        set { store.dispatch(SetPrefsFlagAction(flag: .muteSpeaking, enabled: newValue)) }
    }

    @objc dynamic var muteClicker: Bool {
        get { flag(.muteClicker) }
        set { store.dispatch(SetPrefsFlagAction(flag: .muteClicker, enabled: newValue)) }
    }

    @objc dynamic var muteBell: Bool {
        get { flag(.muteBell) }
        set { store.dispatch(SetPrefsFlagAction(flag: .muteBell, enabled: newValue)) }
    }

    @objc dynamic var updatingEnabled: Bool {
        get { store.state.prefs.updatingEnabled }
        set { store.dispatch(SetUpdatingEnabledAction(newValue)) }
    }

    private func flag(_ flag: PrefsFlags) -> Bool {
        store.state.prefs.flags.contains(flag)
    }
}
