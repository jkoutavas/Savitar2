//
//  EventsContentViewController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Root content for the Events window: compact list (left) + detail editor (right).
final class EventsContentViewController: NSViewController {
    /// Width for the trigger/macro table; detail pane fills the remainder of the 900pt window.
    static let listPaneWidth: CGFloat = 440

    var eventsViewController: EventsViewController?
    var detailViewController: DetailsTabViewController?

    var store: ReactionsStore? {
        didSet { wireStore() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for child in children {
            if let eventsViewController = child as? EventsViewController {
                self.eventsViewController = eventsViewController
            } else if let detailViewController = child as? DetailsTabViewController {
                self.detailViewController = detailViewController
            }
        }
        wireStore()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            SavitarHelpButton.installInTitleBar(of: window, for: .eventsWindow)
        }
    }

    private func wireStore() {
        eventsViewController?.detailViewController = detailViewController
        eventsViewController?.store = store
        detailViewController?.setStore(store)
    }
}
