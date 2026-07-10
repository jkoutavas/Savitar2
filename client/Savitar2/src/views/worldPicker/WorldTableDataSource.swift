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
    var store: WorldsStore?
}

extension WorldTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return listModel?.itemCount ?? 0
    }
}

extension WorldTableDataSource: ItemTableDataSourceType {
    var selectedRow: Int? { return listModel?.selectedRow }
    var selectedItem: WorldViewModel? { return listModel?.selectedItem }
    var itemCount: Int { return listModel?.itemCount ?? 0 }

    func getStore() -> WorldsStore? {
        return store
    }

    func setStore(_ store: WorldsStore?) {
        self.store = store
    }

    func updateContents(listModel: WorldListViewModel) {
        self.listModel = listModel
    }

    func itemCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let viewModel = listModel?.viewModels[row] else { return nil }
        let cell = tableView.makeView(
            withIdentifier: WorldPickerRowCell.reuseID,
            owner: self
        ) as? WorldPickerRowCell ?? WorldPickerRowCell()
        cell.identifier = WorldPickerRowCell.reuseID
        cell.update(viewModel: viewModel)
        return cell
    }
}
