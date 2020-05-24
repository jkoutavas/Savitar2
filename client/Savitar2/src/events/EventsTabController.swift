//
//  EventsTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol EventsTabControllerType {
    func setStore(reactionsStore: ReactionsStore?)
}

class EventsTabController: NSViewController, EventsTabControllerType {
    @IBOutlet var tableView: NSTableView!

    internal var store: ReactionsStore? {
        didSet {
            setStore(reactionsStore: store)
        }
    }

    func setStore(reactionsStore: ReactionsStore?) {} // ovveride this
}
