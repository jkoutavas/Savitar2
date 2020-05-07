//
//  EventsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class EventsViewController: NSTabViewController {
    var store: ReactionsStore?

    override func viewWillAppear() {
        super.viewWillAppear()

        for tabViewItem in tabViewItems {
            if let tabVC = tabViewItem.viewController as? EventsTabController {
                tabVC.store = store
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        for tabViewItem in tabViewItems {
            if let tabVC = tabViewItem.viewController as? EventsTabController {
                tabVC.store = nil
            }
        }
    }
}

class EventsTabController: NSViewController {
    @IBOutlet var tableView: NSTableView!

    var store: ReactionsStore?
}
