//
//  InputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class InputSettingsController: NSViewController {
    @IBOutlet var echoBox: NSBox!
    @IBOutlet var noEchoRadio: NSButton!
    @IBOutlet var echoCROnlyRadio: NSButton!
    @IBOutlet var echoAllRadio: NSButton!
    @IBOutlet var cmdMarkerLabel: NSTextField!
    @IBOutlet var cmdMarkerField: NSTextField!
    @IBOutlet var stickyCommandsButton: NSButton!

    private var crOnlyRadio: NSButton!
    private var crLfRadio: NSButton!
    private var varMarkerField: NSTextField!
    private var wildMarkerField: NSTextField!
    private var lineEndingBox: NSBox!
    private var didInstallLayout = false

    @objc dynamic var inputRows: Int {
        get { (representedObject as? World)?.inputRows ?? 2 }
        set { (representedObject as? World)?.inputRows = max(1, newValue) }
    }

    @objc dynamic var stickyCommands: Bool {
        get {
            guard let world = representedObject as? World else { return false }
            return world.flags.contains(.stickyCmds)
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            if value {
                world.flags.insert(.stickyCmds)
            } else {
                world.flags.remove(.stickyCmds)
            }
        }
    }

    @objc dynamic var cmdMarker: String {
        get {
            guard let world = representedObject as? World else { return "##" }
            return world.cmdMarker
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.cmdMarker = value
        }
    }

    @objc dynamic var varMarker: String {
        get {
            guard let world = representedObject as? World else { return "%%" }
            return world.varMarker
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.varMarker = value
        }
    }

    @objc dynamic var wildMarker: String {
        get {
            guard let world = representedObject as? World else { return "$$" }
            return world.wildMarker
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.wildMarker = value
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installLayout()
        syncEchoRadios()
        syncLineEndingRadios()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        syncEchoRadios()
        syncLineEndingRadios()
    }

    @IBAction func echoRadioButtonChanged(_: AnyObject) {
        guard let world = representedObject as? World else { return }

        if noEchoRadio.state == .on {
            world.flags.remove([.echoCmds, .echoCR])
        } else if echoCROnlyRadio.state == .on {
            world.flags.remove(.echoCmds)
            world.flags.insert(.echoCR)
        } else {
            world.flags.remove(.echoCR)
            world.flags.insert(.echoCmds)
        }
    }

    @objc private func lineEndingRadioButtonChanged(_: AnyObject) {
        guard let world = representedObject as? World else { return }

        if crOnlyRadio.state == .on {
            world.flags.insert(.crOnly)
        } else {
            world.flags.remove(.crOnly)
        }
    }

    private func syncEchoRadios() {
        guard let world = representedObject as? World else { return }

        noEchoRadio.state = !world.flags.contains(.echoCmds) && !world.flags.contains(.echoCR) ? .on : .off
        echoCROnlyRadio.state = world.flags.contains(.echoCR) ? .on : .off
        echoAllRadio.state = world.flags.contains(.echoCmds) ? .on : .off
    }

    private func syncLineEndingRadios() {
        guard let world = representedObject as? World else { return }

        crOnlyRadio.state = world.flags.contains(.crOnly) ? .on : .off
        crLfRadio.state = world.flags.contains(.crOnly) ? .off : .on
    }

    private func installLayout() {
        guard !didInstallLayout else { return }
        didInstallLayout = true

        let layoutViews: [NSView] = [
            echoBox,
            cmdMarkerLabel,
            cmdMarkerField,
            stickyCommandsButton
        ]
        layoutViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        varMarkerField = markerField(bindingKeyPath: "self.varMarker")
        wildMarkerField = markerField(bindingKeyPath: "self.wildMarker")

        let varLabel = labelField(title: "Variable marker:")
        let wildLabel = labelField(title: "Wildcard marker:")
        let markerStack = NSStackView(views: [
            markerRow(label: varLabel, field: varMarkerField),
            markerRow(label: wildLabel, field: wildMarkerField)
        ])
        markerStack.orientation = .vertical
        markerStack.alignment = .leading
        markerStack.spacing = 8
        markerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(markerStack)

        lineEndingBox = NSBox()
        lineEndingBox.title = "Line ending"
        lineEndingBox.boxType = .primary
        lineEndingBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineEndingBox)

        crOnlyRadio = lineEndingRadio(title: "Carriage return only (CR)", tag: 1)
        crLfRadio = lineEndingRadio(title: "Carriage return + line feed (CR/LF)", tag: 2)

        let lineEndingContent = NSStackView(views: [crOnlyRadio, crLfRadio])
        lineEndingContent.orientation = .vertical
        lineEndingContent.alignment = .leading
        lineEndingContent.spacing = 6
        lineEndingContent.translatesAutoresizingMaskIntoConstraints = false
        lineEndingBox.contentView = NSView()
        lineEndingBox.contentView?.addSubview(lineEndingContent)

        let margin: CGFloat = 20
        let spacing: CGFloat = 12

        _ = inputRowsContent

        NSLayoutConstraint.activate([
            echoBox.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            echoBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            echoBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            cmdMarkerLabel.topAnchor.constraint(equalTo: echoBox.bottomAnchor, constant: spacing),
            cmdMarkerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            cmdMarkerField.centerYAnchor.constraint(equalTo: cmdMarkerLabel.centerYAnchor),
            cmdMarkerField.leadingAnchor.constraint(equalTo: cmdMarkerLabel.trailingAnchor, constant: 8),
            cmdMarkerField.widthAnchor.constraint(equalToConstant: 64),

            stickyCommandsButton.topAnchor.constraint(equalTo: cmdMarkerLabel.bottomAnchor, constant: spacing),
            stickyCommandsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            markerStack.topAnchor.constraint(equalTo: stickyCommandsButton.bottomAnchor, constant: spacing),
            markerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            markerStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -margin),

            lineEndingBox.topAnchor.constraint(equalTo: markerStack.bottomAnchor, constant: spacing),
            lineEndingBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            lineEndingBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            lineEndingContent.leadingAnchor.constraint(
                equalTo: lineEndingBox.contentView!.leadingAnchor, constant: 16),
            lineEndingContent.trailingAnchor.constraint(
                equalTo: lineEndingBox.contentView!.trailingAnchor, constant: -16),
            lineEndingContent.topAnchor.constraint(
                equalTo: lineEndingBox.contentView!.topAnchor, constant: 14),
            lineEndingContent.bottomAnchor.constraint(
                equalTo: lineEndingBox.contentView!.bottomAnchor, constant: -14),

            inputRowsBox.topAnchor.constraint(equalTo: lineEndingBox.bottomAnchor, constant: spacing),
            inputRowsBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            inputRowsBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            inputRowsBox.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -margin),

            inputRowsContent.leadingAnchor.constraint(
                equalTo: inputRowsBox.contentView!.leadingAnchor, constant: 16),
            inputRowsContent.trailingAnchor.constraint(
                equalTo: inputRowsBox.contentView!.trailingAnchor, constant: -16),
            inputRowsContent.topAnchor.constraint(equalTo: inputRowsBox.contentView!.topAnchor, constant: 14),
            inputRowsContent.bottomAnchor.constraint(equalTo: inputRowsBox.contentView!.bottomAnchor, constant: -14)
        ])
    }

    private lazy var inputRowsBox: NSBox = {
        let box = NSBox()
        box.title = "Input Pane"
        box.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(box)
        return box
    }()

    private lazy var inputRowsContent: NSStackView = {
        let help = NSTextField(wrappingLabelWithString:
            "Height of the command-entry pane in text rows.")
        help.font = NSFont.systemFont(ofSize: 11)
        help.textColor = .secondaryLabelColor

        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 64).isActive = true
        field.alignment = .right
        field.formatter = PaneDimensionFormatter.shared
        field.bind(.value, to: self, withKeyPath: "inputRows", options: [
            .continuouslyUpdatesValue: true
        ])

        let row = NSStackView(views: [NSTextField(labelWithString: "Input rows:"), field])
        row.orientation = .horizontal
        row.spacing = 8

        let stack = NSStackView(views: [help, row])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        inputRowsBox.contentView?.addSubview(stack)
        return stack
    }()

    private func labelField(title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private func markerField(bindingKeyPath: String) -> NSTextField {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 64).isActive = true
        field.bind(.value, to: self, withKeyPath: bindingKeyPath, options: [
            .continuouslyUpdatesValue: true
        ])
        return field
    }

    private func markerRow(label: NSTextField, field: NSTextField) -> NSView {
        let row = NSStackView(views: [label, field])
        row.orientation = .horizontal
        row.spacing = 8
        return row
    }

    private func lineEndingRadio(title: String, tag: Int) -> NSButton {
        let button = NSButton(
            radioButtonWithTitle: title,
            target: self,
            action: #selector(lineEndingRadioButtonChanged(_:)))
        button.tag = tag
        return button
    }
}
