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
    var detailViewController: NSTabViewController?

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

    // **************************************

    // MARK: - NSTabViewControllerDelegate

    // **************************************

    override func tabView(_: NSTabView, didSelect _: NSTabViewItem?) {
        // Keep the detail tab selection in lock-step with the events tab selection
        if let vc = detailViewController {
            vc.selectedTabViewItemIndex = selectedTabViewItemIndex
        }
    }
}

extension EventsViewController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(newItem(_:)) {
            menuItem.title = selectedTabViewItemIndex == 0 ? "New Trigger" : "New Macro"
        }
        return true
    }

    @IBAction func newItem(_: Any) {
        guard let tabVC = tabViewItems[selectedTabViewItemIndex].viewController as? EventsTabController else { return }
        tabVC.addItem(self)
    }
}
