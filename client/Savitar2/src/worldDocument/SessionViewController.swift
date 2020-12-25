//
//  SessionViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/22/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

enum InputPanelType: Int {
    case Input = 0
    case Connecting = 1
    case Offline = 2
    case Unreachable = 3
}

class SessionViewController: NSSplitViewController {
    var session: Session?

    func select(panel: InputPanelType) {
        let item = splitViewItems[1]
        guard let tabController = item.viewController as? NSTabViewController else { return }
        if let statusVC = tabController.tabViewItems[panel.rawValue].viewController as? ConnectionStatusViewController {
            statusVC.session = session
        }
        tabController.selectedTabViewItemIndex = panel.rawValue
    }

    var inputViewController: InputViewController? {
        let item = splitViewItems[1]
        guard let tabController = item.viewController as? NSTabViewController else {
            return nil
        }
        guard let vc = tabController.tabViewItems[0].viewController as? InputViewController else {
            return nil
        }
        return vc
    }

    var outputViewController: OutputViewController? {
        let item = splitViewItems[0]
        guard let vc = item.viewController as? OutputViewController else {
            return nil
        }
        return vc
    }
}
