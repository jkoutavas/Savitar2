//
//  InputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class InputSettingsController: NSViewController {
    @IBOutlet var noEchoRadio: NSButton!
    @IBOutlet var echoCROnlyRadio: NSButton!
    @IBOutlet var echoAllRadio: NSButton!
    @IBOutlet var stickyCommandsButton: NSButton!

    private var crOnlyRadio: NSButton!
    private var crLfRadio: NSButton!
    private var varMarkerField: NSTextField!
    private var wildMarkerField: NSTextField!

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

        installMarkerFields()
        installLineEndingControls()
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

    private func installMarkerFields() {
        let varLabel = labelField(title: "Variable marker:")
        let wildLabel = labelField(title: "Wildcard marker:")
        varMarkerField = markerField(bindingKeyPath: "self.varMarker")
        wildMarkerField = markerField(bindingKeyPath: "self.wildMarker")

        let stack = NSStackView(views: [
            markerRow(label: varLabel, field: varMarkerField),
            markerRow(label: wildLabel, field: wildMarkerField)
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: stickyCommandsButton.bottomAnchor, constant: 12)
        ])
    }

    private func installLineEndingControls() {
        let box = NSBox()
        box.title = "Line ending"
        box.boxType = .primary
        box.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(box)

        crOnlyRadio = lineEndingRadio(title: "Carriage return only (CR)", tag: 1)
        crLfRadio = lineEndingRadio(title: "Carriage return + line feed (CR/LF)", tag: 2)

        let content = NSStackView(views: [crOnlyRadio, crLfRadio])
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 6
        content.translatesAutoresizingMaskIntoConstraints = false
        box.contentView = NSView()
        box.contentView?.addSubview(content)

        NSLayoutConstraint.activate([
            box.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            box.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            box.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),

            content.leadingAnchor.constraint(equalTo: box.contentView!.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: box.contentView!.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: box.contentView!.topAnchor, constant: 14),
            content.bottomAnchor.constraint(equalTo: box.contentView!.bottomAnchor, constant: -14)
        ])
    }

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
        let button = NSButton(radioButtonWithTitle: title, target: self, action: #selector(lineEndingRadioButtonChanged(_:)))
        button.tag = tag
        return button
    }
}
