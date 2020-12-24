//
//  WorldSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/15/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WorldSettingsController: NSViewController {
    var completionHandler: ((Bool, World?) -> Void)?

    var world: World? {
        get {
            return _editedWorld
        }
        set {
            // copy the world. We'll manipulate it in settings, and if the
            // user hits 'apply' we'll copy the changes back.
            _editedWorld = newValue?.copy() as? World

            // we set the tab controllers' world here in the world setter
            // instead of prepare(for segue:) because prepare(for segue:)
            // gets called at storyboard instantiation, before we have
            // the chance to set the world value
            for viewItem in (_tabViewController?.tabViewItems)! {
                viewItem.viewController?.representedObject = _editedWorld!
            }
        }
    }

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
        completionHandler?(true, _editedWorld)
    }

    @IBAction func cancelWorldSetting(_ sender: Any) {
        completionHandler?(false, nil)
    }
}
