//
//  WorldSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/15/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WorldSettingsController: NSViewController {
    var docController : NSWindowController? // needed for closeWorldSettings
    
    var world : World? {
        get {
            return _world
        }
        set {
            _world = newValue
            // we set the tab controllers' world here in the world setter
            // instead of prepare(for segue:) because prepare(for segue:)
            // gets called at storyboard instantiation, before we have
            // the chance to set the world value
            for vc in (_tabViewController?.childViewControllers)! {
                vc.representedObject = _world
            }
        }
    }
    
    private var _world: World?
    private var _tabViewController: NSTabViewController?
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // grab a reference to the tabViewController, we'll use it in the
        // world setter to propagate the world down into the tab controllers
        if segue.destinationController is NSTabViewController {
            _tabViewController = segue.destinationController as? NSTabViewController
        }
    }
    
    @IBAction func closeWorldSetting(_ sender: Any) {
        docController?.window!.endSheet(self.view.window!)
    }
}
