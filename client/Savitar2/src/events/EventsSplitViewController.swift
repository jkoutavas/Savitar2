//
//  EventsSplitViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/20/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsSplitViewController: NSSplitViewController {
    var eventsViewController: EventsViewController?
    var detailViewController: NSTabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let eventsViewController = children.first as? EventsViewController,
           let detailViewController = children.last as? NSTabViewController {
            self.eventsViewController = eventsViewController
            eventsViewController.detailViewController = detailViewController
        }
    }
}
