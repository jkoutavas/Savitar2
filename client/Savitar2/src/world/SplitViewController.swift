//
//  SplitViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/22/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    var inputViewController: InputViewController {
        let item = splitViewItems[1]
        return item.viewController as! InputViewController
    }
    
    var outputViewController: OutputViewController {
        let item = splitViewItems[0]
        return item.viewController as! OutputViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
