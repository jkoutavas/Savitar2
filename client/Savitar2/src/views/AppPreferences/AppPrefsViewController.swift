//
//  AppPrefsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/5/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

private struct CheckboxBinding {
    let button: NSButton
    let keyPath: String
    let supported: Bool
}

private struct AppearancePopupBinding {
    let popup: NSPopUpButton
    let keyPath = "appAppearanceMode"
}

class AppPrefsViewController: NSViewController, StoreSubscriber {
    var store: AppPreferencesStore? {
        didSet {
            speechPrefsViewController?.store = store
            speechPrefsViewController?.activateIfNeeded()
        }
    }
    weak var settingsWindowController: AppSettingsWindowController?

    private static let contentMargin: CGFloat = 20

    private let paneContainer = NSView()
    private var paneViews: [AppSettingsPane: NSView] = [:]
    private var visiblePane: AppSettingsPane = .startup
    private var speechPrefsViewController: SpeechPrefsViewController?
    private var colorsSettingsViewController: ColorsSettingsViewController?
    private var checkboxBindings: [CheckboxBinding] = []
    private var appearancePopupBinding: AppearancePopupBinding?

    override func viewDidLoad() {
        super.viewDidLoad()
        buildSettingsPanes()
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

    func showPane(_ pane: AppSettingsPane) {
        visiblePane = pane
        for (paneKey, paneView) in paneViews {
            paneView.isHidden = paneKey != pane
        }
        if pane == .speech {
            speechPrefsViewController?.activateIfNeeded()
        }
    }

    func fittingSizeForVisiblePane() -> NSSize {
        guard let paneView = paneViews[visiblePane] else {
            return view.fittingSize
        }
        paneView.layoutSubtreeIfNeeded()
        let margin = Self.contentMargin * 2
        return NSSize(width: paneView.fittingSize.width + margin, height: paneView.fittingSize.height + margin)
    }

    func maximumPaneContentSize() -> NSSize {
        let margin = Self.contentMargin * 2
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        for paneView in paneViews.values {
            paneView.layoutSubtreeIfNeeded()
            let size = paneView.fittingSize
            maxWidth = max(maxWidth, size.width + margin)
            maxHeight = max(maxHeight, size.height + margin)
        }
        return NSSize(width: maxWidth, height: maxHeight)
    }

    private func buildSettingsPanes() {
        view.subviews.forEach { $0.removeFromSuperview() }
        checkboxBindings.removeAll()
        appearancePopupBinding = nil
        paneViews.removeAll()
        speechPrefsViewController = nil
        colorsSettingsViewController = nil

        paneContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paneContainer)

        let margin = Self.contentMargin
        NSLayoutConstraint.activate([
            paneContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            paneContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            paneContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            paneContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        ])

        paneViews[.startup] = paneView(items: [
            .enabled("showStartupPicker", title: "Show World Picker at startup"),
            .enabled("showStartupClicker", title: "Show Macro Clicker at startup"),
            .enabled("showEventsWindowAtStartup", title: "Show Events Window at startup")
        ])

        paneViews[.inputDisplay] = inputDisplayPaneView()

        paneViews[.audio] = paneView(items: [
            .enabled("muteSound", title: "Mute sound cues"),
            .enabled("muteSpeaking", title: "Mute speaking cues"),
            .enabled("muteClicker", title: "Mute clicker sounds"),
            .enabled("muteBell", title: "Mute terminal bell")
        ])

        paneViews[.updates] = paneView(items: [
            .enabled("updatingEnabled", title: "Check for updates automatically")
        ])

        paneViews[.colors] = colorsPaneView()

        paneViews[.speech] = speechPaneView()

        paneViews[.advanced] = advancedPaneView()

        for paneView in paneViews.values {
            paneView.translatesAutoresizingMaskIntoConstraints = false
            paneContainer.addSubview(paneView)
            NSLayoutConstraint.activate([
                paneView.leadingAnchor.constraint(equalTo: paneContainer.leadingAnchor),
                paneView.trailingAnchor.constraint(equalTo: paneContainer.trailingAnchor),
                paneView.topAnchor.constraint(equalTo: paneContainer.topAnchor),
                paneView.bottomAnchor.constraint(equalTo: paneContainer.bottomAnchor)
            ])
        }

        let initialPane = settingsWindowController?.selectedPane ?? .startup
        showPane(initialPane)
        settingsWindowController?.resizeToFitCurrentPane()
    }

    private func inputDisplayPaneView() -> NSView {
        let paneView = NSView()
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(sectionHeader("Appearance"))

        let appearanceRow = NSStackView()
        appearanceRow.orientation = .horizontal
        appearanceRow.alignment = .centerY
        appearanceRow.spacing = 8
        appearanceRow.translatesAutoresizingMaskIntoConstraints = false

        let appearanceLabel = NSTextField(labelWithString: "App appearance:")
        appearanceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let appearancePopup = NSPopUpButton(frame: .zero, pullsDown: false)
        for mode in AppAppearanceMode.allCases {
            appearancePopup.addItem(withTitle: mode.menuTitle)
            appearancePopup.lastItem?.tag = mode.rawValue
        }
        appearancePopupBinding = AppearancePopupBinding(popup: appearancePopup)
        appearanceRow.addArrangedSubview(appearanceLabel)
        appearanceRow.addArrangedSubview(appearancePopup)
        stack.addArrangedSubview(appearanceRow)

        let appearanceFootnote = NSTextField(wrappingLabelWithString:
            "System follows macOS light/dark setting. "
                + "Light and Dark apply to app windows and dialogs, not MUD session colors."
        )
        appearanceFootnote.font = NSFont.systemFont(ofSize: 11)
        appearanceFootnote.textColor = .secondaryLabelColor
        appearanceFootnote.preferredMaxLayoutWidth = 420
        stack.addArrangedSubview(appearanceFootnote)

        stack.addArrangedSubview(sectionHeader("Input"))

        for item in [
            CheckboxItem.enabled("useKeypad", title: "Use keypad for macro entry"),
            CheckboxItem.enabled("monoFontsOnly", title: "Mono fonts only (in font menus)"),
            CheckboxItem.enabled("defaultWordWrap", title: "Default word wrap for new sessions")
        ] {
            let checkbox = NSButton(checkboxWithTitle: checkboxTitle(item), target: nil, action: nil)
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            switch item {
            case let .enabled(keyPath, _):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                checkboxBindings.append(CheckboxBinding(button: checkbox, keyPath: keyPath, supported: true))
            case let .disabled(keyPath, _, toolTip):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                styleUnsupportedCheckbox(checkbox, toolTip: toolTip)
                checkboxBindings.append(CheckboxBinding(button: checkbox, keyPath: keyPath, supported: false))
            }
            stack.addArrangedSubview(checkbox)
        }

        paneView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: paneView.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: paneView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: paneView.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: paneView.bottomAnchor)
        ])
        return paneView
    }

    private func sectionHeader(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        return label
    }

    private func speechPaneView() -> NSView {
        let speechViewController = SpeechPrefsViewController()
        speechViewController.store = store
        addChild(speechViewController)
        speechPrefsViewController = speechViewController
        _ = speechViewController.view
        speechViewController.activateIfNeeded()
        return speechViewController.view
    }

    private func colorsPaneView() -> NSView {
        let colorsViewController = ColorsSettingsViewController()
        addChild(colorsViewController)
        colorsSettingsViewController = colorsViewController
        return colorsViewController.view
    }

    private func advancedPaneView() -> NSView {
        let advancedViewController = AdvancedSettingsViewController()
        addChild(advancedViewController)
        _ = advancedViewController.view
        return advancedViewController.view
    }

    private enum CheckboxItem {
        case enabled(String, title: String)
        case disabled(String, title: String, toolTip: String)
    }

    private func paneView(items: [CheckboxItem]) -> NSView {
        let paneView = NSView()
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        for item in items {
            let checkbox = NSButton(checkboxWithTitle: checkboxTitle(item), target: nil, action: nil)
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            switch item {
            case let .enabled(keyPath, _):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                checkboxBindings.append(CheckboxBinding(button: checkbox, keyPath: keyPath, supported: true))
            case let .disabled(keyPath, _, toolTip):
                checkbox.identifier = NSUserInterfaceItemIdentifier(keyPath)
                styleUnsupportedCheckbox(checkbox, toolTip: toolTip)
                checkboxBindings.append(CheckboxBinding(button: checkbox, keyPath: keyPath, supported: false))
            }
            stack.addArrangedSubview(checkbox)
        }

        paneView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: paneView.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: paneView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: paneView.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: paneView.bottomAnchor)
        ])
        return paneView
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
        if let binding = appearancePopupBinding {
            binding.popup.bind(.selectedTag, to: presenter, withKeyPath: binding.keyPath, options: bindOptions)
        }
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
        if let appearancePopup = appearancePopupBinding?.popup {
            appearancePopup.unbind(.selectedTag)
        }
        for entry in checkboxBindings where entry.supported {
            entry.button.unbind(.value)
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

    @objc dynamic var appAppearanceMode: Int {
        get { store.state.prefs.appearanceMode.rawValue }
        set {
            guard let mode = AppAppearanceMode(rawValue: newValue) else { return }
            store.dispatch(SetAppAppearanceModeAction(mode: mode))
        }
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
