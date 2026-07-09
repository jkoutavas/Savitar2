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

        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            box.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            box.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            boxContent.leadingAnchor.constraint(equalTo: box.contentView!.leadingAnchor, constant: 16),
            boxContent.trailingAnchor.constraint(equalTo: box.contentView!.trailingAnchor, constant: -16),
            boxContent.topAnchor.constraint(equalTo: box.contentView!.topAnchor, constant: 14),
            boxContent.bottomAnchor.constraint(equalTo: box.contentView!.bottomAnchor, constant: -14),

            field.widthAnchor.constraint(greaterThanOrEqualToConstant: 240)
        ])
    }
}
