//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController : NSWindowController {
    var readOnly = false
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        let components = displayName.components(separatedBy: ".")
        
        // display just the world's file name, with no extension. And, if the
        // world is read-only (v1.0) then append an indication of that.
        return components[0] + (readOnly ? " [READ ONLY]" : "")
    }
    
    @IBAction func openWorldSetting(_ sender: Any) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "WorldSettings"), bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "TabViewController")) as! NSTabViewController
        self.contentViewController?.presentViewControllerAsSheet(controller)
    }
}
