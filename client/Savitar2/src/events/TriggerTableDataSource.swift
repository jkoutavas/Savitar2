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

//    let emptyTrigger = TriggerViewModel(identifier: "unknown", name: "unknown")
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
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
            as? NSTableCellView else { return nil }
        guard let textField = cell.textField else { return nil }

        if let tViewModel = viewModel?.triggers[row] {
            if tableColumn == tableView.tableColumns[0] {
                textField.stringValue = tViewModel.name
            } else if tableColumn == tableView.tableColumns[1] {
                textField.stringValue = tViewModel.type
            } else {
                textField.stringValue = tViewModel.audioCue
            }
        }

        return cell
    }
}
