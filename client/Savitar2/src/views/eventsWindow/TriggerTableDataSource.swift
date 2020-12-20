//
//  TriggerTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/25/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

typealias TriggerListViewModel = ListViewModel<TriggerViewModel>

class TriggerTableDataSource: NSObject, ReactionsStoreSetter {
    var listModel: TriggerListViewModel?
    var store: ReactionsStore?
}

extension TriggerTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return listModel?.itemCount ?? 0
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let viewModel = listModel?.viewModels[safe: row] else { return nil }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier) else { return nil }
        guard let object = store?.state?.triggerList.item(objectID: objID) else { return nil }
        return TriggerPasteboardWriter(object: object, at: row)
     }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if let source = info.draggingSource as? NSTableView, source === tableView {
            // We're moving an item within the same tableview
            tableView.draggingDestinationFeedbackStyle = .gap
            return .move
        } else {
            // We're copying an item from another table view
            tableView.draggingDestinationFeedbackStyle = .regular
            return .copy
        }
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }

        if let source = info.draggingSource as? NSTableView, source === tableView {
            // We're moving an item within the same tableview
            let indexes = items.compactMap {$0.integer(forType: .tableViewIndex)}
            if !indexes.isEmpty {
                store?.dispatch(MoveTriggerAction(from: indexes[0], to: row))
                return true
            }
        } else {
            // We're copying an item from another table view
            let triggers = items.compactMap { $0.string(forType: .trigger) }
            if !triggers.isEmpty {
                do {
                    let xml = try XML.parse(triggers[0])
                    let elem = xml[TriggerElemIdentifier]
                    if case .failure = elem {
                        return false
                    }
                    let trigger = Trigger()
                    try trigger.parse(xml: elem)
                    store?.dispatch(InsertTriggerAction(trigger: trigger, atIndex: row))
                    return true
                } catch {
                    return false
                }
            }
        }

        return false
    }
}

extension TriggerTableDataSource: ItemTableDataSourceType {
    var selectedRow: Int? { return listModel?.selectedRow }
    var selectedItem: TriggerViewModel? { return listModel?.selectedItem }
    var itemCount: Int { return listModel?.itemCount ?? 0 }

    func getStore() -> ReactionsStore? {
        return store
    }

    func setStore(_ store: ReactionsStore?) {
        self.store = store
    }

    func updateContents(listModel: TriggerListViewModel) {
        self.listModel = listModel
    }

    func itemCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        func setTextField(_ cell: NSTableCellView, _ value: String) {
            guard let textField = cell.textField else { return }
            textField.stringValue = value
        }
        guard let viewModel = listModel?.viewModels[row] else { return nil }
        switch tableColumn {
        case tableView.tableColumns[0]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? CheckableTableCellView else { return nil }
            cell.checkableItemChangeDelegate = self
            cell.viewModel = viewModel
            return cell

        case tableView.tableColumns[1]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView else { return nil }
            setTextField(cell, viewModel.type)
            return cell

        case tableView.tableColumns[2]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView else { return nil }
            setTextField(cell, viewModel.audioCue)
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
            case false: return TriggerAction.disable(triggerID)
            case true: return TriggerAction.enable(triggerID)
            }
        }()

        store?.dispatch(action)
    }

}
