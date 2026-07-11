//
//  OutputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 05/07/21.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class OutputSettingsController: NSViewController {
    @IBOutlet var appendLoggingRadio: NSButton!
    @IBOutlet var overwriteLoggingRadio: NSButton!

    private weak var loggingEnabledButton: NSButton?
    private weak var logFileBox: NSBox?

    private var didInstallLayout = false

    @objc dynamic var outputRows: Int {
        get { (representedObject as? World)?.outputRows ?? 24 }
        set { (representedObject as? World)?.outputRows = max(1, newValue) }
    }

    @objc dynamic var columns: Int {
        get { (representedObject as? World)?.columns ?? 80 }
        set { (representedObject as? World)?.columns = max(1, newValue) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installLayoutIfNeeded()

        guard let world = representedObject as? World else { return }
        appendLoggingRadio.state = world.loggingType == World.LoggingType.append ? .on : .off
        overwriteLoggingRadio.state = world.loggingType == World.LoggingType.overwrite ? .on : .off
    }

    @objc dynamic var logfilePath: String {
        get {
            guard let world = representedObject as? World else { return "" }
            return world.logfilePath
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.logfilePath = value
        }
    }

    @IBAction func loggingRadioButtonChanged(_: AnyObject) {
        guard let world = representedObject as? World else { return }

        if appendLoggingRadio.state == .on {
            world.loggingType = World.LoggingType.append
        } else {
            world.loggingType = World.LoggingType.overwrite
        }
    }

    @IBAction func fileSaveAction(_: AnyObject) {
        guard let world = representedObject as? World else { return }
        guard let settingsWindow = view.window else { return }
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["txt"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Set your log file's location"
        savePanel.message = "Choose a folder and a name to store your log."
        savePanel.prompt = "Set now"
        savePanel.beginSheetModal(for: settingsWindow) { result in
            if result == .OK, let fileUrl = savePanel.url {
                world.logfilePath = fileUrl.path
            }
        }
    }

    private func installLayoutIfNeeded() {
        guard !didInstallLayout else { return }
        didInstallLayout = true

        loggingEnabledButton = view.subviews.compactMap { $0 as? NSButton }
            .first { $0.title == "Logging Enabled" }
        logFileBox = view.subviews.compactMap { $0 as? NSBox }
            .first { $0.title == "Log File" }
        guard let loggingEnabledButton, let logFileBox else { return }

        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        let margin: CGFloat = 18
        let spacing: CGFloat = 12

        let paneSizeBox = NSBox()
        paneSizeBox.title = "Pane Size"
        paneSizeBox.translatesAutoresizingMaskIntoConstraints = false

        let paneHelp = NSTextField(wrappingLabelWithString:
            "Output pane width and height in text columns and rows. Best with monospace fonts.")
        paneHelp.font = NSFont.systemFont(ofSize: 11)
        paneHelp.textColor = .secondaryLabelColor

        let columnsField = dimensionField(binding: "columns")
        let outputRowsField = dimensionField(binding: "outputRows")
        let columnsRow = labeledRow(title: "Columns:", field: columnsField)
        let rowsRow = labeledRow(title: "Output rows:", field: outputRowsField)

        let paneContent = NSStackView(views: [paneHelp, columnsRow, rowsRow])
        paneContent.orientation = .vertical
        paneContent.alignment = .leading
        paneContent.spacing = 8
        paneContent.translatesAutoresizingMaskIntoConstraints = false
        paneSizeBox.contentView?.addSubview(paneContent)

        view.addSubview(paneSizeBox)

        NSLayoutConstraint.activate([
            loggingEnabledButton.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            loggingEnabledButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            paneSizeBox.topAnchor.constraint(equalTo: loggingEnabledButton.bottomAnchor, constant: spacing),
            paneSizeBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            paneSizeBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            paneContent.leadingAnchor.constraint(equalTo: paneSizeBox.contentView!.leadingAnchor, constant: 16),
            paneContent.trailingAnchor.constraint(equalTo: paneSizeBox.contentView!.trailingAnchor, constant: -16),
            paneContent.topAnchor.constraint(equalTo: paneSizeBox.contentView!.topAnchor, constant: 14),
            paneContent.bottomAnchor.constraint(equalTo: paneSizeBox.contentView!.bottomAnchor, constant: -14),

            logFileBox.topAnchor.constraint(equalTo: paneSizeBox.bottomAnchor, constant: spacing),
            logFileBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            logFileBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            logFileBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        ])
    }

    private func dimensionField(binding: String) -> NSTextField {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 64).isActive = true
        field.alignment = .right
        field.formatter = PaneDimensionFormatter.shared
        field.bind(.value, to: self, withKeyPath: binding, options: [
            .continuouslyUpdatesValue: true
        ])
        return field
    }

    private func labeledRow(title: String, field: NSTextField) -> NSView {
        let label = NSTextField(labelWithString: title)
        label.setContentHuggingPriority(.required, for: .horizontal)
        let row = NSStackView(views: [label, field])
        row.orientation = .horizontal
        row.spacing = 8
        return row
    }
}

/// Shared integer formatter for pane row/column fields (min 1).
final class PaneDimensionFormatter: NumberFormatter, @unchecked Sendable {
    static let shared: PaneDimensionFormatter = {
        let formatter = PaneDimensionFormatter()
        formatter.minimum = 1
        formatter.maximum = 999
        formatter.allowsFloats = false
        formatter.generatesDecimalNumbers = false
        return formatter
    }()
}
