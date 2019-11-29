//
//  SplitViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/22/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    var inputViewController: InputViewController? {
        let item = splitViewItems[1]
        guard let vc = item.viewController as? InputViewController else {
            return nil
        }
        return vc
    }

    var outputViewController: OutputViewController? {
        let item = splitViewItems[0]
        guard let vc = item.viewController as? OutputViewController else {
            return nil
        }
        return vc
    }

}
