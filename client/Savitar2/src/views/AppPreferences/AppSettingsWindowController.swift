//
//  AppSettingsWindowController.swift
//  Savitar2
//
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Cocoa

enum AppSettingsPane: Int, CaseIterable {
    case startup
    case inputDisplay
    case colors
    case audio
    case updates
    case speech
    case advanced

    var title: String {
        switch self {
        case .startup: return "Startup"
        case .inputDisplay: return "Input & Display"
        case .colors: return "Colors"
        case .audio: return "Audio"
        case .updates: return "Updates"
        case .speech: return "Speech"
        case .advanced: return "Advanced"
        }
    }

    var toolbarItemIdentifier: NSToolbarItem.Identifier {
        NSToolbarItem.Identifier("Savitar2.AppSettings.\(rawValue)")
    }

    static func pane(for identifier: NSToolbarItem.Identifier) -> AppSettingsPane? {
        allCases.first { $0.toolbarItemIdentifier == identifier }
    }

    var symbolName: String {
        switch self {
        case .startup: return "play.circle"
        case .inputDisplay: return "keyboard"
        case .colors: return "paintpalette"
        case .audio: return "speaker.wave.2"
        case .updates: return "arrow.down.circle"
        case .speech: return "person.wave.2"
        case .advanced: return "gearshape.2"
        }
    }
}

final class AppSettingsWindowController: NSWindowController, NSToolbarDelegate {
    static let toolbarIdentifier = NSToolbar.Identifier("Savitar2AppSettingsToolbar")

    private(set) var selectedPane: AppSettingsPane = .startup
    var initialPane: AppSettingsPane = .startup
    private var hasCentered = false
    private var escapeKeyMonitor: Any?

    private var settingsViewController: AppPrefsViewController? {
        contentViewController as? AppPrefsViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window else { return }

        window.configureAsSettingsWindow(delegate: self)
        setupToolbar(on: window)
        installEscapeKeyMonitor()
        settingsViewController?.settingsWindowController = self
        selectPane(initialPane)
        SavitarHelpButton.installInTitleBar(of: window, for: .appSettings(initialPane))
    }

    deinit {
        if let escapeKeyMonitor {
            NSEvent.removeMonitor(escapeKeyMonitor)
        }
    }

    private func installEscapeKeyMonitor() {
        escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, window?.isKeyWindow == true else { return event }
            if event.keyCode == 53 {
                cancelOperation(self)
                return nil
            }
            if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "." {
                cancelOperation(self)
                return nil
            }
            return event
        }
    }

    func selectPane(_ pane: AppSettingsPane) {
        selectedPane = pane
        settingsViewController?.showPane(pane)
        window?.title = pane.title
        if let window {
            SavitarHelpButton.installInTitleBar(of: window, for: .appSettings(pane))
        }
        if #available(macOS 11.0, *) {
            window?.toolbar?.selectedItemIdentifier = pane.toolbarItemIdentifier
        }
        resizeToFitCurrentPane()
    }

    func resizeToFitCurrentPane() {
        guard let window, let settingsViewController else { return }
        let paneSize = settingsViewController.fittingSizeForVisiblePane()
        let maxPaneSize = settingsViewController.maximumPaneContentSize()
        let width = max(paneSize.width, maxPaneSize.width, estimatedToolbarWidth())
        let height = max(paneSize.height, maxPaneSize.height)
        window.fitContentSize(NSSize(width: width, height: height), centerIfNeeded: !hasCentered)
        if !hasCentered {
            hasCentered = true
        }
    }

    /// Width needed to show every Settings toolbar tab with icon + label (no overflow chevron).
    private func estimatedToolbarWidth() -> CGFloat {
        let font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        let iconWidth: CGFloat = 18
        let itemPadding: CGFloat = 20
        var width: CGFloat = 48
        for pane in AppSettingsPane.allCases {
            let labelWidth = (pane.title as NSString).size(withAttributes: [.font: font]).width
            width += iconWidth + labelWidth + itemPadding
        }
        return ceil(width)
    }

    override func cancelOperation(_ sender: Any?) {
        window?.close()
    }

    @objc private func toolbarPaneAction(_ sender: NSToolbarItem) {
        guard let pane = AppSettingsPane.pane(for: sender.itemIdentifier) else { return }
        selectPane(pane)
    }

    private func setupToolbar(on window: NSWindow) {
        let toolbar = NSToolbar(identifier: Self.toolbarIdentifier)
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        window.toolbar = toolbar
        if #available(macOS 11.0, *) {
            window.toolbarStyle = .preference
        }
    }

    // MARK: - NSToolbarDelegate

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        guard let pane = AppSettingsPane.pane(for: itemIdentifier) else { return nil }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = pane.title
        item.paletteLabel = pane.title
        item.toolTip = pane.title
        if #available(macOS 11.0, *) {
            item.image = NSImage(systemSymbolName: pane.symbolName, accessibilityDescription: pane.title)
        }
        item.target = self
        item.action = #selector(toolbarPaneAction(_:))
        return item
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        AppSettingsPane.allCases.map(\.toolbarItemIdentifier)
    }

    func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(NSToolbar())
    }

    func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        if #available(macOS 11.0, *) {
            return toolbarDefaultItemIdentifiers(NSToolbar())
        }
        return []
    }

    @available(macOS 11.0, *)
    func toolbar(_: NSToolbar, didSelectItemWith itemIdentifier: NSToolbarItem.Identifier) {
        guard let pane = AppSettingsPane.pane(for: itemIdentifier) else { return }
        selectPane(pane)
    }
}

extension AppSettingsWindowController: NSWindowDelegate {
    func windowWillClose(_: Notification) {
        AppContext.shared.appPrefsWindowDidClose()
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        AppContext.shared.appUndoManager
    }
}
