//
//  WorldTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

typealias WorldListViewModel = ListViewModel<WorldViewModel>

class WorldTableDataSource: NSObject {
    var listModel: WorldListViewModel?
}

extension WorldTableDataSource: NSTableViewDataSource {
}
