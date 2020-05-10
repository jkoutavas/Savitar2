//
//  VariableTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class VariableTableDataSource: NSObject {
    var viewModel: VariablesViewModel?
    var store: ReactionsStore?
}

extension VariableTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return viewModel?.itemCount ?? 0
    }
}

extension VariableTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}

extension VariableTableDataSource: VariableTableDataSourceType {
    var selectedRow: Int? { return viewModel?.selectedRow }
    var selectedVariable: VariableViewModel? { return viewModel?.selectedVariable }
    var variableCount: Int { return viewModel?.itemCount ?? 0 }

    func getStore() -> ReactionsStore? {
        return store
    }

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    func updateContents(variablesViewModel viewModel: VariablesViewModel) {
        self.viewModel = viewModel
    }

    func variableCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
            as? NSTableCellView else { return nil }
        guard let textField = cell.textField else { return nil }

        if let vViewModel = viewModel?.variables[row] {
            if tableColumn == tableView.tableColumns[0] {
                textField.stringValue = vViewModel.name
            } else if tableColumn == tableView.tableColumns[1] {
                textField.stringValue = vViewModel.hotKey
            } else {
                textField.stringValue = vViewModel.value
            }
        }

        return cell
    }
}
