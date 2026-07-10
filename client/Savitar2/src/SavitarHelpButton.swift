//
//  SavitarHelpButton.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Contextual help surfaces (Story 17). Maps UI → guide anchor.
extension SavitarHelp {
    enum ContextualSurface: Equatable {
        case eventsWindow
        case appSettings(AppSettingsPane)
        case worldSettings(SavitarHelp.WorldSettingsTab)
        case worldPicker
        case worldSession

        var anchor: String {
            switch self {
            case .eventsWindow:
                return Anchor.events
            case .appSettings(let pane):
                return pane.helpAnchor
            case .worldSettings(let tab):
                return tab.helpAnchor
            case .worldPicker:
                return Anchor.worldsConnectionWorldPicker
            case .worldSession:
                return Anchor.worldMenu
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .eventsWindow:
                return "Help for Events window"
            case .appSettings(let pane):
                return "Help for \(pane.title) settings"
            case .worldSettings(let tab):
                return "Help for World Settings \(tab.title) tab"
            case .worldPicker:
                return "Help for World Picker"
            case .worldSession:
                return "Help for world session window"
            }
        }

        var toolTip: String {
            switch self {
            case .eventsWindow:
                return "Open help for triggers and macros"
            case .appSettings(let pane):
                return pane.helpToolTip
            case .worldSettings(let tab):
                return tab.helpToolTip
            case .worldPicker:
                return "Open help for choosing and opening worlds"
            case .worldSession:
                return "Open help for the world window and World menu"
            }
        }

        /// One title-bar accessory per window kind; App Settings reuses the same accessory when the pane changes.
        fileprivate var titlebarAccessoryID: String {
            switch self {
            case .appSettings:
                return "savitar-contextual-help-appSettings"
            case .eventsWindow:
                return "savitar-contextual-help-eventsWindow"
            case .worldSettings:
                return "savitar-contextual-help-worldSettings"
            case .worldPicker:
                return "savitar-contextual-help-worldPicker"
            case .worldSession:
                return "savitar-contextual-help-worldSession"
            }
        }

        fileprivate var storageKey: String {
            switch self {
            case .eventsWindow:
                return "eventsWindow"
            case .appSettings(let pane):
                return "appSettings.\(pane.rawValue)"
            case .worldSettings(let tab):
                return "worldSettings.\(tab.rawValue)"
            case .worldPicker:
                return "worldPicker"
            case .worldSession:
                return "worldSession"
            }
        }

        func show() {
            SavitarHelp.show(anchor: anchor)
        }
    }
}

private extension AppSettingsPane {
    var helpAnchor: String {
        switch self {
        case .speech:
            return SavitarHelp.Anchor.speechSettingsReference
        case .audio:
            return SavitarHelp.Anchor.audio
        case .startup:
            return SavitarHelp.Anchor.gettingStarted
        case .inputDisplay:
            return SavitarHelp.Anchor.inputDisplay
        case .colors:
            return SavitarHelp.Anchor.ansiColors
        case .updates:
            return SavitarHelp.Anchor.updates
        case .advanced:
            return SavitarHelp.Anchor.settingsAdvanced
        }
    }

    var helpToolTip: String {
        switch self {
        case .speech:
            return "Open help for Speech settings"
        case .audio:
            return "Open help for sound, speech, and bell mute options"
        case .startup:
            return "Open help for World Picker and Events at startup"
        case .inputDisplay:
            return "Open help for keypad and font menu options"
        case .colors:
            return "Open help for the ANSI color palette"
        case .updates:
            return "Open help for automatic and manual updates"
        case .advanced:
            return "Open help for restoring factory defaults and maintenance"
        }
    }
}

/// Standard **?** help control for contextual guide links (Story 17).
enum SavitarHelpButton {
    private static var surfacesByKey: [String: SavitarHelp.ContextualSurface] = [:]

    static func make(for surface: SavitarHelp.ContextualSurface) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .helpButton
        button.controlSize = .small
        button.title = ""
        button.target = HelpActionTarget.shared
        button.action = #selector(HelpActionTarget.showHelp(_:))
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 22),
            button.heightAnchor.constraint(equalToConstant: 22)
        ])
        configure(button, for: surface)
        return button
    }

    /// Adds or updates a trailing title-bar **?** for the given surface.
    static func installInTitleBar(of window: NSWindow, for surface: SavitarHelp.ContextualSurface) {
        let accessoryID = NSUserInterfaceItemIdentifier(surface.titlebarAccessoryID)
        if let existing = window.titlebarAccessoryViewControllers.first(where: { $0.identifier == accessoryID }),
           let button = helpButton(in: existing.view) {
            configure(button, for: surface)
            return
        }

        let button = make(for: surface)
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 34, height: 28))
        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor)
        ])

        let accessory = NSTitlebarAccessoryViewController()
        accessory.identifier = accessoryID
        accessory.layoutAttribute = .right
        accessory.view = container
        window.addTitlebarAccessoryViewController(accessory)
    }

    private static let inViewHelpButtonTag = 9_001_017

    /// Pin **?** in the top-trailing corner of a view. Use for sheets and panels that hide title-bar accessories.
    static func installInTopTrailingCorner(of view: NSView, for surface: SavitarHelp.ContextualSurface) {
        if let existing = view.viewWithTag(inViewHelpButtonTag) as? NSButton {
            configure(existing, for: surface)
            return
        }

        let button = make(for: surface)
        button.tag = inViewHelpButtonTag
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
        ])
    }

    fileprivate static func surface(for button: NSButton) -> SavitarHelp.ContextualSurface? {
        guard let key = button.identifier?.rawValue else { return nil }
        return surfacesByKey[key]
    }

    private static func configure(_ button: NSButton, for surface: SavitarHelp.ContextualSurface) {
        button.toolTip = surface.toolTip
        button.setAccessibilityLabel(surface.accessibilityLabel)
        button.setAccessibilityHelp("Opens the Savitar user guide to the relevant chapter.")
        button.identifier = NSUserInterfaceItemIdentifier(surface.storageKey)
        surfacesByKey[surface.storageKey] = surface
    }

    private static func helpButton(in view: NSView) -> NSButton? {
        if let button = view as? NSButton, button.action == #selector(HelpActionTarget.showHelp(_:)) {
            return button
        }
        for subview in view.subviews {
            if let button = helpButton(in: subview) {
                return button
            }
        }
        return nil
    }
}

/// Shared target so storyboard-free help buttons do not retain their host view controller.
private final class HelpActionTarget: NSObject {
    static let shared = HelpActionTarget()

    @objc func showHelp(_ sender: NSButton) {
        guard let surface = SavitarHelpButton.surface(for: sender) else { return }
        surface.show()
    }
}
