//
//  WorldPickerController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol WorldTableDataSourceType {
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedWorld: WorldViewModel? { get }
    var worldCount: Int { get }

    func updateContents(worldsViewModel viewModel: WorldsViewModel)
    func getStore() -> ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?)
    func worldCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

class WorldPickerController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
}
