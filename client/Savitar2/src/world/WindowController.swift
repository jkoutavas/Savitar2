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
        return components[0] + (world?.version != 2 ? " [READ ONLY]" : "")
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is WorldSettingsController
        {
            let vc = segue.destinationController as? WorldSettingsController
            vc?.world = world
        }
    }

    @IBAction func showWorldSetting(_ sender: Any) {
        titlebarController?.performSegue(withIdentifier:NSStoryboardSegue.Identifier(rawValue: "ShowWorldSettings"), sender: self)
    }
 /*
    @IBAction func closeWorldSetting(_ sender: Any) {
        self.dismissViewController(settingsSheet!)
        settingsSheet = nil
    }
*/   
}
