//
//  EventsTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsTabController: NSViewController, ReactionsStoreSetter {
    @IBOutlet weak var tableView: NSTableView!

    internal var store: ReactionsStore? {
        didSet {
            setStore(store)
        }
    }

    func setStore(_ store: ReactionsStore?) {
        fatalError("Must Override")
    }
}
