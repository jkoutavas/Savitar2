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
    var detailViewController: DetailsTabViewController?

    internal var store: ReactionsStore? {
        didSet {
            if let evc = eventsViewController {
                evc.detailViewController = detailViewController
                evc.store = store
            }
            if let dvc = detailViewController {
                dvc.setStore(reactionsStore: store)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let eventsViewController = children.first as? EventsViewController,
           let detailViewController = children.last as? DetailsTabViewController {
            self.eventsViewController = eventsViewController
            self.detailViewController = detailViewController
        }
    }
}
