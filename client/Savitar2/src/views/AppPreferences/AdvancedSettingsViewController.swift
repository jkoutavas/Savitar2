//
//  AdvancedSettingsViewController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Settings → Advanced: factory reset and other rare maintenance actions.
final class AdvancedSettingsViewController: NSViewController {
    private let introLabel = NSTextField(wrappingLabelWithString: "")
    private let scopeLabel = NSTextField(wrappingLabelWithString: "")
    private let preserveLabel = NSTextField(wrappingLabelWithString: "")
    private let restoreButton = NSButton(title: "Restore Factory Defaults…", target: nil, action: nil)

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
        installLayout()
        restoreButton.target = self
        restoreButton.action = #selector(restoreFactoryDefaultsAction(_:))
        restoreButton.bezelStyle = .rounded
    }

    @objc private func restoreFactoryDefaultsAction(_: Any) {
        let alert = NSAlert()
        alert.messageText = "Restore factory defaults?"
        alert.informativeText = """
            Savitar will replace all app settings with the original factory configuration, \
            including the World Picker world list, universal triggers and macros, and the ANSI color palette.

            Saved world documents on disk are not deleted. This cannot be undone.
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Restore Defaults")
        alert.buttons[0].keyEquivalent = "\r"

        guard alert.runModal() == .alertSecondButtonReturn else { return }
        AppContext.shared.restoreFactoryDefaults()
    }

    private func configureLabels() {
        introLabel.stringValue = "Restore the app to its original configuration."
        scopeLabel.stringValue = """
            • App settings (startup, input, audio, updates, speech)
            • World Picker world list and connection addresses
            • Universal triggers and macros
            • ANSI color palette
            • Saved positions for utility windows (World Picker, Events, Macro Clicker)
            """
        preserveLabel.stringValue = "Saved world documents on disk are not deleted."

        for label in [introLabel, scopeLabel, preserveLabel] {
            label.isSelectable = false
            label.isEditable = false
            label.drawsBackground = false
            label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            if label !== introLabel {
                label.textColor = .secondaryLabelColor
            }
            label.preferredMaxLayoutWidth = 420
        }
        introLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
    }

    private func installLayout() {
        for item in [introLabel, scopeLabel, preserveLabel, restoreButton] {
            item.translatesAutoresizingMaskIntoConstraints = false
        }

        let stack = NSStackView(views: [introLabel, scopeLabel, preserveLabel, restoreButton])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.setCustomSpacing(20, after: preserveLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }
}
