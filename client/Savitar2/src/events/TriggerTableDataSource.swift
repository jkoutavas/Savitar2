//
//  TriggerTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/25/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TriggerTableDataSource: NSObject {
    var viewModel: TriggersViewModel?
    var store: ReactionsStore?
}

extension TriggerTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return viewModel?.itemCount ?? 0
    }
}

extension TriggerTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}

extension TriggerTableDataSource: TriggerTableDataSourceType {
    var selectedRow: Int? { return viewModel?.selectedRow }
    var selectedTrigger: TriggerViewModel? { return viewModel?.selectedTrigger }
    var triggerCount: Int { return viewModel?.itemCount ?? 0 }

    func getStore() -> ReactionsStore? {
        return store
    }

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    func updateContents(triggersViewModel viewModel: TriggersViewModel) {
        self.viewModel = viewModel
    }

    func triggerCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        func setTextField(_ cell: NSTableCellView, _ value: String) {
            guard let textField = cell.textField else { return }
            textField.stringValue = value
        }
        guard let tViewModel = viewModel?.triggers[row] else { return nil }
        switch tableColumn {
        case tableView.tableColumns[0]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? CheckableTableCellView else { return nil }
            cell.checkableItemChangeDelegate = self
            cell.viewModel = tViewModel
            return cell
        case tableView.tableColumns[1]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView else { return nil }
            setTextField(cell, tViewModel.type)
            return cell
        case tableView.tableColumns[2]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView else { return nil }
            setTextField(cell, tViewModel.audioCue)
            return cell
        default:
            return nil
        }
     }
}

extension TriggerTableDataSource: CheckableItemChangeDelegate {
    func checkableItem(identifier: String, didChangeChecked checked: Bool) {
        guard let triggerID = SavitarObjectID(identifier: identifier)
            else { preconditionFailure("Invalid Trigger identifier \(identifier).") }

        let action: TriggerAction = {
            switch checked {
            case true: return TriggerAction.enable(triggerID)
            case false: return TriggerAction.disable(triggerID)
            }
        }()

        store?.dispatch(action)
    }

}
