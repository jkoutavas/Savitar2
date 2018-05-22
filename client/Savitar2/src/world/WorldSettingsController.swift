//
//  WorldSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/15/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WorldSettingsController: NSViewController {
    var windowController: WindowController? // needed for closeWorldSettings

    var world: World? {
        get {
            return _editedWorld
        }
        set {
            _origWorld = newValue
            // copy the world. We'll manipulate it in settings, and if the
            // user hits 'apply' we'll copy the changes back.
            _editedWorld = _origWorld?.copy() as? World

            // we set the tab controllers' world here in the world setter
            // instead of prepare(for segue:) because prepare(for segue:)
            // gets called at storyboard instantiation, before we have
            // the chance to set the world value
            for vc in (_tabViewController?.childViewControllers)! {
                vc.representedObject = _editedWorld
            }
        }
    }

    private var _origWorld: World?
    private var _editedWorld: World?
    private var _tabViewController: NSTabViewController?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // grab a reference to the tabViewController, we'll use it in the
        // world setter to propagate the world down into the tab controllers
        if segue.destinationController is NSTabViewController {
            _tabViewController = segue.destinationController as? NSTabViewController
        }
    }

    @IBAction func applyWorldSetting(_ sender: Any) {
        windowController?.window!.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse(rawValue: 1))
        windowController?.world = _editedWorld
    }

    @IBAction func cancelWorldSetting(_ sender: Any) {
        windowController?.window!.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse(rawValue: 0))
    }
}
