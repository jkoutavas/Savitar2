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

    @IBOutlet weak var fontPopup: NSPopUpButton!
    @IBOutlet weak var monoFontPopup: NSPopUpButton!
    @IBOutlet weak var outputView: OutputView!

    override func viewDidLoad() {
        super.viewDidLoad()
        for family in NSFontManager.shared.availableFontFamilies {
            let font = NSFont(name: family, size: 11)
            let menuItem = NSMenuItem.init()
            menuItem.title = family
            fontPopup.menu?.addItem(menuItem)
            if font!.isFixedPitch {
                let menuItem = NSMenuItem.init()
                menuItem.title = family
                monoFontPopup.menu?.addItem(menuItem)
            }
         }

        guard let wc = self.representedObject as? WorldController else { return }

        fontPopup.selectItem(withTitle: wc.world.fontName)
        monoFontPopup.selectItem(withTitle: wc.world.monoFontName)
        attributeChanged()
    }

    override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
        attributeChanged()
    }

    @IBAction func fontPopUpButtonWasSelected(sender: AnyObject) {
        guard let wc = self.representedObject as? WorldController else { return }

        if let popup = sender as? NSPopUpButton, let family = popup.selectedItem?.title {
            wc.world.fontName = family
            attributeChanged()
        }
    }

    @IBAction func monoFontPopUpButtonWasSelected(sender: AnyObject) {
        guard let wc = self.representedObject as? WorldController else { return }

        if let popup = sender as? NSPopUpButton, let family = popup.selectedItem?.title {
            wc.world.monoFontName = family
            attributeChanged()
        }
    }

    func attributeChanged() {
        guard let wc = self.representedObject as? WorldController else { return }

        outputView.clear()
        outputView.setStyle(world: wc.world)

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
}
