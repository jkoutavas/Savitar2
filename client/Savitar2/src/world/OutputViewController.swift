//
//  OutputViewConroller.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/1/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import AppKit

class OutputViewController : ViewController {
    
    var showSheet: Bool = false
    
    lazy var sheetViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SheetViewController"))
        as! NSViewController
    }()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if showSheet {
            self.presentViewControllerAsSheet(sheetViewController)
        }
    }
}
