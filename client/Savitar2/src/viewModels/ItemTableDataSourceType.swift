//
//  ItemTableDataSourceType.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol ItemTableDataSourceType {
    associatedtype ItemViewModelT
    associatedtype ListViewModelT
    associatedtype StoreT
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedItem: ItemViewModelT? { get }
    var itemCount: Int { get }

    func updateContents(listModel: ListViewModelT)
    func getStore() -> StoreT?
    func setStore(_ store: StoreT?)
    func itemCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

extension ItemTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}
