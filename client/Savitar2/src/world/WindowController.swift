//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController : NSWindowController {
    var titlebarController : NSTitlebarAccessoryViewController?
    var world : World?
    
    override func windowDidLoad() {
        titlebarController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "titlebarViewController"))
            as? NSTitlebarAccessoryViewController
        titlebarController?.layoutAttribute = .right
        // layoutAttribute has to be set before added to window
        self.window?.addTitlebarAccessoryViewController(titlebarController!)
    }

    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        let components = displayName.components(separatedBy: ".")
        
        // display just the world's file name, with no extension. And, if the
        // world is read-only (v1.0) then append an indication of that.
        var status = ""
        if let editable = world?.editable {
            if !editable {
                status = " [READ ONLY]"
            }
        }
        return components[0] + status
    }

    @IBAction func showWorldSetting(_ sender: Any) {
        let vc = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WorldSettings")) as! WorldSettingsController
        vc.world = world
        titlebarController?.presentViewControllerAsSheet(vc)
 
    }
 /*
    @IBAction func closeWorldSetting(_ sender: Any) {
        self.dismissViewController(settingsSheet!)
        settingsSheet = nil
    }
*/   
}
