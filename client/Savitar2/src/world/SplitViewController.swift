//
//  SplitViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/22/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    func selectInputViewController() {
        let item = splitViewItems[1]
        guard let tabController = item.viewController as? NSTabViewController else { return }
        tabController.selectedTabViewItemIndex = 0
    }

    func selectOfflineViewController() {
        let item = splitViewItems[1]
        guard let tabController = item.viewController as? NSTabViewController else { return }
        tabController.selectedTabViewItemIndex = 1
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
