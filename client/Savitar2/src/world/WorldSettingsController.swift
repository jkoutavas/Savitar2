//
//  WorldSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/15/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WorldSettingsController: NSViewController {
    var world : World?
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
     if segue.destinationController is NSTabViewController
        {
            let tabViewController = segue.destinationController as? NSTabViewController
            for object in (tabViewController?.childViewControllers)! {
                let childViewController = object as NSViewController
                childViewController.representedObject = world
            }
        }
    }
}
