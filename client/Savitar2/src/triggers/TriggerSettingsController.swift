//
//  TriggerSettingsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/10/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TriggerSettingsController: NSViewController {

    @IBOutlet var tabView: NSTabView!

    var applyChange = false
     
    var trigger: Trigger? {
         get {
            return _editedTrigger
        }
        set {
            _origTrigger = newValue
            // copy the trigger. We'll manipulate it in settings, and if the
            // user hits 'okay' we'll copy the changes back.
            _editedTrigger = _origTrigger?.copy() as? Trigger

            self.representedObject = TriggerController(trigger: _editedTrigger!)

            // we set the tab controllers' trigger here in the trigger setter
            // instead of prepare(for segue:) because prepare(for segue:)
            // gets called at storyboard instantiation, before we have
            // the chance to set the trigger value
            for viewItem in (tabView?.tabViewItems)! {
                viewItem.viewController?.representedObject = TriggerController(trigger: _editedTrigger!)
            }
        }
    }

    @IBAction func cancelTriggerWindow(_ sender: NSButton) {
        applyChange = false
        NSApplication.shared.stopModal()
    }

    @IBAction func okayTriggerWindow(_ sender: NSButton) {
        _origTrigger = _editedTrigger
        applyChange = true
        NSApplication.shared.stopModal()
    }

    private var _origTrigger: Trigger?
    private var _editedTrigger: Trigger?
}
