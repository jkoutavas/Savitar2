//
//  ClosingSettingsController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

class ClosingSettingsController: NSViewController {
    private var didInstallLayout = false

    @objc dynamic var logoffCmd: String {
        get { (representedObject as? World)?.logoffCmd ?? "" }
        set { (representedObject as? World)?.logoffCmd = newValue }
    }

    @objc dynamic var autoClose: Bool {
        get { (representedObject as? World)?.flags.contains(.autoClose) ?? false }
        set { setAutoClose(enabled: newValue) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installLayoutIfNeeded()
    }

    private func installLayoutIfNeeded() {
        guard !didInstallLayout else { return }
        didInstallLayout = true

        let margin: CGFloat = 18
        let spacing: CGFloat = 12

        let help = NSTextField(wrappingLabelWithString:
            "When you close a connected session window, Savitar sends this command to the world before " +
            "disconnecting. Use your game’s quit command (for example quit, @quit, or QUIT). " +
            "Leave blank to disconnect without sending a command.")
        help.font = NSFont.systemFont(ofSize: 11)
        help.textColor = .secondaryLabelColor
        help.preferredMaxLayoutWidth = 380

        let autoCloseButton = NSButton(checkboxWithTitle:
            "Close window automatically (do not show reconnect prompt)", target: nil, action: nil)
        autoCloseButton.translatesAutoresizingMaskIntoConstraints = false
        autoCloseButton.bind(.value, to: self, withKeyPath: "autoClose", options: [
            .continuouslyUpdatesValue: true
        ])

        let autoCloseHelp = NSTextField(wrappingLabelWithString:
            "When off, closing a connected window disconnects and shows the offline panel—you close " +
            "again to dismiss the document. When on, the window closes immediately after disconnect.")
        autoCloseHelp.font = NSFont.systemFont(ofSize: 11)
        autoCloseHelp.textColor = .secondaryLabelColor
        autoCloseHelp.preferredMaxLayoutWidth = 380

        let box = NSBox()
        box.title = "Logoff command"
        box.translatesAutoresizingMaskIntoConstraints = false

        let fieldLabel = NSTextField(labelWithString: "Command:")
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholderString = "quit"
        field.bind(.value, to: self, withKeyPath: "logoffCmd", options: [
            .continuouslyUpdatesValue: true
        ])

        let row = NSStackView(views: [fieldLabel, field])
        row.orientation = .horizontal
        row.spacing = 8
        row.alignment = .centerY
        row.translatesAutoresizingMaskIntoConstraints = false
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let boxContent = NSStackView(views: [help, row])
        boxContent.orientation = .vertical
        boxContent.alignment = .leading
        boxContent.spacing = 10
        boxContent.translatesAutoresizingMaskIntoConstraints = false
        box.contentView?.addSubview(boxContent)

        view.addSubview(box)

        let autoCloseBox = NSBox()
        autoCloseBox.title = "Close behavior"
        autoCloseBox.translatesAutoresizingMaskIntoConstraints = false

        let autoCloseContent = NSStackView(views: [autoCloseButton, autoCloseHelp])
        autoCloseContent.orientation = .vertical
        autoCloseContent.alignment = .leading
        autoCloseContent.spacing = 8
        autoCloseContent.translatesAutoresizingMaskIntoConstraints = false
        autoCloseBox.contentView?.addSubview(autoCloseContent)

        view.addSubview(autoCloseBox)

        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            box.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            box.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            boxContent.leadingAnchor.constraint(equalTo: box.contentView!.leadingAnchor, constant: 16),
            boxContent.trailingAnchor.constraint(equalTo: box.contentView!.trailingAnchor, constant: -16),
            boxContent.topAnchor.constraint(equalTo: box.contentView!.topAnchor, constant: 14),
            boxContent.bottomAnchor.constraint(equalTo: box.contentView!.bottomAnchor, constant: -14),

            field.widthAnchor.constraint(greaterThanOrEqualToConstant: 240),

            autoCloseBox.topAnchor.constraint(equalTo: box.bottomAnchor, constant: spacing),
            autoCloseBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            autoCloseBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            autoCloseContent.leadingAnchor.constraint(
                equalTo: autoCloseBox.contentView!.leadingAnchor, constant: 16),
            autoCloseContent.trailingAnchor.constraint(
                equalTo: autoCloseBox.contentView!.trailingAnchor, constant: -16),
            autoCloseContent.topAnchor.constraint(equalTo: autoCloseBox.contentView!.topAnchor, constant: 14),
            autoCloseContent.bottomAnchor.constraint(equalTo: autoCloseBox.contentView!.bottomAnchor, constant: -14),

            autoCloseBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        ])
    }

    private func setAutoClose(enabled: Bool) {
        guard let world = representedObject as? World else { return }
        if enabled {
            world.flags.insert(.autoClose)
        } else {
            world.flags.remove(.autoClose)
        }
    }
}
