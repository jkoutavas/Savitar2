//
//  AppearanceSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class AppearanceSettingsController: NSViewController {

    @IBOutlet var textView: NSTextView!

    @objc dynamic let appearanceTextUrl = Bundle.main.url(forResource: "Appearance", withExtension: "txt")

    override func viewDidLoad() {
        super.viewDidLoad()

        attributeChanged()
    }

    @IBAction func attributeChangedAction(_ sender: Any) {
        attributeChanged()
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
