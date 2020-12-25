//
//  EventsTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsTabController: NSViewController, ReactionsStoreSetter {
    @IBOutlet var tableView: NSTableView!

    internal var store: ReactionsStore? {
        didSet {
            setStore(store)
        }
    }

    func setStore(_: ReactionsStore?) {
        fatalError("Must Override")
    }
}
