//
//  EventsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class EventsViewController: NSTabViewController, NSWindowDelegate {
    var store: ReactionsStore?
    var detailViewController: NSTabViewController?

    override func viewWillAppear() {
        super.viewWillAppear()

        view.window!.delegate = self

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

    //**************************************
    // MARK: - NSTabViewControllerDelegate
    //**************************************

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        // Keep the detail tab selection in lock-step with the events tab selection
        if let vc = self.detailViewController {
            vc.selectedTabViewItemIndex = selectedTabViewItemIndex
        }
    }

    //***************************
    // MARK: - NSWindowDelegate
    //***************************

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return globalStoreUndoManagerProvider.undoManager
    }

    func windowWillClose(_ notification: Notification) {
        // Only remove the startupEventsWindow flag if the user has closed the window. (windowWillClose gets called
        // on application termination too.)
        if !AppContext.shared.isTerminating {
            AppContext.shared.prefs.flags.remove(.startupEventsWindow)
            AppContext.shared.save()
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
        if selectedTabViewItemIndex == 0 {
            store?.dispatch(InsertTriggerAction(trigger: Trigger(), atIndex: 0))
        } else {
            store?.dispatch(InsertMacroAction(macro: Macro(), atIndex: 0))
        }
    }
}
