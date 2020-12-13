//
//  WorldTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class WorldTableDataSource: NSObject {
    var viewModel: WorldsViewModel?
}

extension WorldTableDataSource: NSTableViewDataSource {
}

extension WorldTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}
