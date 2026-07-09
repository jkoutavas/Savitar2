//
//  WorldSettingsTabViewController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// World Settings sheet tabs in the window toolbar (HIG).
class WorldSettingsTabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabStyle = .toolbar
        for item in tabViewItems {
            item.label = item.viewController?.title ?? ""
        }
    }
}
