//
//  AppearanceSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class AppearanceSettingsController: NSViewController, WKNavigationDelegate {

    @IBOutlet var fontPopup: NSPopUpButton!
    @IBOutlet var webView: WKWebView!
 
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
        
        if let filepath = Bundle.main.path(forResource: "Appearance", ofType: "html") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let esc = "\u{1B}"
                webView.output(string:contents.replacingOccurrences(of: "^[", with: "\(esc)["))
            } catch {
                // contents could not be loaded
            }
        }
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
        webView.setStyle(world:world)
    }
}
