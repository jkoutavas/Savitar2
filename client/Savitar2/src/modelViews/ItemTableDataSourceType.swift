//
//  ItemTableDataSourceType.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol ItemTableDataSourceType {
    associatedtype ItemViewModel
    associatedtype ListViewModel
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedItem: ItemViewModel? { get }
    var itemCount: Int { get }

    func updateContents(listModel: ListViewModel)
    func getStore() -> ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?)
    func itemCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

extension ItemTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}

