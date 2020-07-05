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
}
