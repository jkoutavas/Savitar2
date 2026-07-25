//
//  AppearanceSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class AppearanceSettingsController: OutputViewNavigationDelegate {
    @IBOutlet var fontPopup: NSPopUpButton!
    @IBOutlet var monoFontPopup: NSPopUpButton!
    @IBOutlet var outputView: OutputView!

    private var intenseColorWell: NSColorWell?
    private var intenseRadios: [NSButton] = []
    private var didInstallIntenseControls = false

    override func viewDidLoad() {
        super.viewDidLoad()
        outputView.setWordWrap(true)
        let monoOnly = AppContext.shared.prefs.flags.contains(.monoFontsOnly)
        for family in NSFontManager.shared.availableFontFamilies {
            let font = NSFont(name: family, size: 11)
            let isMono = font?.isFixedPitch ?? false
            if !monoOnly || isMono {
                let menuItem = NSMenuItem()
                menuItem.title = family
                fontPopup.menu?.addItem(menuItem)
            }
            if isMono {
                let menuItem = NSMenuItem()
                menuItem.title = family
                monoFontPopup.menu?.addItem(menuItem)
            }
        }

        installIntenseControlsIfNeeded()

        guard let world = representedObject as? World else { return }

        fontPopup.selectItem(withTitle: world.fontName)
        monoFontPopup.selectItem(withTitle: world.monoFontName)
        syncIntenseControls(from: world)
        attributeChanged()
    }

    override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
        if keyPath == "representedObject.intensityType" {
            updateIntenseColorWellEnabled()
        }
        attributeChanged()
    }

    @IBAction func fontPopUpButtonWasSelected(sender: AnyObject) {
        guard let world = representedObject as? World else { return }

        if let popup = sender as? NSPopUpButton, let family = popup.selectedItem?.title {
            world.fontName = family
            attributeChanged()
        }
    }

    @IBAction func monoFontPopUpButtonWasSelected(sender: AnyObject) {
        guard let world = representedObject as? World else { return }

        if let popup = sender as? NSPopUpButton, let family = popup.selectedItem?.title {
            world.monoFontName = family
            attributeChanged()
        }
    }

    @objc private func intenseTypeRadioChanged(_ sender: NSButton) {
        guard let world = representedObject as? World,
              let type = IntensityType(rawValue: sender.tag) else { return }
        world.intensityType = type
        updateIntenseColorWellEnabled()
        attributeChanged()
    }

    func attributeChanged() {
        guard let world = representedObject as? World else { return }

        outputView.clear()
        outputView.setStyle(world: world)

        if let filepath = Bundle.main.path(forResource: "Appearance", ofType: "txt") {
            let esc = "\u{1B}"
            do {
                let contents = try String(contentsOfFile: filepath)
                outputView.output(string: contents.replacingOccurrences(of: "\\n", with: "\n")
                    .replacingOccurrences(of: "\\e", with: "\(esc)"))
            } catch {
                // contents could not be loaded
            }
        }
    }

    private func installIntenseControlsIfNeeded() {
        guard !didInstallIntenseControls, let bodyFontRow = fontPopup.superview else { return }

        // Replace body-font-top → color-well-bottom with body-font → intense → color-wells.
        var colorWellBottomView: NSView?
        var bodyFontTopConstraint: NSLayoutConstraint?
        for constraint in view.constraints where
            (constraint.firstItem as? NSView) === bodyFontRow && constraint.firstAttribute == .top {
            colorWellBottomView = constraint.secondItem as? NSView
            bodyFontTopConstraint = constraint
            break
        }
        guard let colorWellBottomView, let bodyFontTopConstraint else { return }

        didInstallIntenseControls = true
        bodyFontTopConstraint.isActive = false

        let label = NSTextField(labelWithString: "Intense:")
        label.setContentHuggingPriority(.required, for: .horizontal)

        let autoRadio = intenseRadio(title: "Auto", type: .auto)
        let boldRadio = intenseRadio(title: "Bold", type: .bold)
        let colorRadio = intenseRadio(title: "Color", type: .color)
        intenseRadios = [autoRadio, boldRadio, colorRadio]

        let well = NSColorWell()
        well.translatesAutoresizingMaskIntoConstraints = false
        well.focusRingType = .exterior
        well.widthAnchor.constraint(equalToConstant: 44).isActive = true
        well.heightAnchor.constraint(equalToConstant: 23).isActive = true
        well.bind(.value, to: self, withKeyPath: "representedObject.intenseColor", options: [
            .continuouslyUpdatesValue: true
        ])
        intenseColorWell = well

        let row = NSStackView(views: [label, autoRadio, boldRadio, colorRadio, well])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(row)

        // Fixed HTML-box top offset assumed the pre-intense layout height; let the
        // checkbox ↔ box alignment follow the taller control chain instead.
        for constraint in view.constraints {
            guard let box = constraint.firstItem as? NSBox,
                  box.title.contains("Interpret HTML"),
                  constraint.firstAttribute == .top,
                  (constraint.secondItem as? NSView) === view else { continue }
            constraint.isActive = false
            break
        }

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: bodyFontRow.leadingAnchor),
            row.topAnchor.constraint(equalTo: colorWellBottomView.bottomAnchor, constant: 9),
            bodyFontRow.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 8)
        ])

        if let world = representedObject as? World {
            syncIntenseControls(from: world)
        } else {
            updateIntenseColorWellEnabled()
        }
    }

    private func intenseRadio(title: String, type: IntensityType) -> NSButton {
        let button = NSButton(
            radioButtonWithTitle: title,
            target: self,
            action: #selector(intenseTypeRadioChanged(_:)))
        button.tag = type.rawValue
        return button
    }

    private func syncIntenseControls(from world: World) {
        for button in intenseRadios {
            button.state = button.tag == world.intensityType.rawValue ? .on : .off
        }
        updateIntenseColorWellEnabled()
    }

    private func updateIntenseColorWellEnabled() {
        let enabled = (representedObject as? World)?.intensityType == .color
        intenseColorWell?.isEnabled = enabled
    }
}
