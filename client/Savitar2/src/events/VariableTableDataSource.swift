//
//  VariableTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class VariableTableDataSource: NSObject, ReactionStoreSetter {
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
       func setTextField(_ cell: NSTableCellView, _ value: String) {
           guard let textField = cell.textField else { return }
           textField.stringValue = value
       }
       guard let vViewModel = viewModel?.variables[row] else { return nil }
       switch tableColumn {
       case tableView.tableColumns[0]:
           guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
               as? CheckableTableCellView else { return nil }
           cell.checkableItemChangeDelegate = self
           cell.viewModel = vViewModel
           return cell
       case tableView.tableColumns[1]:
           guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
               as? NSTableCellView else { return nil }
           setTextField(cell, vViewModel.hotKey)
           return cell
       case tableView.tableColumns[2]:
           guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
               as? NSTableCellView else { return nil }
           setTextField(cell, vViewModel.value)
           return cell
       default:
           return nil
       }
    }
}

extension VariableTableDataSource: CheckableItemChangeDelegate {
    func checkableItem(identifier: String, didChangeChecked checked: Bool) {
        guard let variableID = SavitarObjectID(identifier: identifier)
            else { preconditionFailure("Invalid Variable identifier \(identifier).") }

        let action: VariableAction = {
            switch checked {
            case true: return VariableAction.enable(variableID)
            case false: return VariableAction.disable(variableID)
            }
        }()

        store?.dispatch(action)
    }
}
