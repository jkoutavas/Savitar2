//
//  AppearanceSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class AppearanceSettingsController: NSViewController {

    @IBOutlet var fontPopup: NSPopUpButton!
    @IBOutlet var textView: NSTextView!
    @objc dynamic let appearanceTextUrl = Bundle.main.url(forResource: "Appearance", withExtension: "txt")

    override func viewDidLoad() {
        super.viewDidLoad()

        for family in NSFontManager.shared.availableFontFamilies {
            let font = NSFont(name: family, size: 13)
            let attrs = [NSAttributedString.Key.font: font ?? NSFont.systemFont(ofSize: 13)]
            let menuItem = NSMenuItem.init()
            menuItem.attributedTitle = NSMutableAttributedString(string: family, attributes: attrs)
            fontPopup.menu?.addItem(menuItem)
         }

        guard let world = self.representedObject as? World else {
            return
        }
        fontPopup.selectItem(withTitle: world.fontName)

        attributeChanged()
     }

    @IBAction func attributeChangedAction(_ sender: Any) {
        attributeChanged()
    }

    @IBAction func fontPopUpButtonWasSelected(sender: AnyObject) {
        guard let world = self.representedObject as? World else {
            return
        }

       if let popup = sender as? NSPopUpButton, let family = popup.selectedItem?.title {
            world.fontName = family
            attributeChanged()
        }
    }

    func attributeChanged() {
        guard let world = self.representedObject as? World else {
            return
        }
        textView.textColor = world.foreColor
        textView.backgroundColor = world.backColor
        textView.font = NSFont(name: world.fontName, size: world.fontSize)
    }
}
