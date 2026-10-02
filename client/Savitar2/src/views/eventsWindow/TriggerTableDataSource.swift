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

    func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let viewModel = listModel?.viewModels[safe: row] else { return nil }
        guard let objID = SavitarObjectID(identifier: viewModel.itemID) else { return nil }
        guard let object = store?.state?.triggerList.item(objectID: objID) else { return nil }
        return TriggerPasteboardWriter(object: object, at: row)
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int,
                   proposedDropOperation _: NSTableView.DropOperation) -> NSDragOperation {
        if let source = info.draggingSource as? NSTableView, source === tableView {
            // We're moving an item within the same tableview
            tableView.setDropRow(row, dropOperation: .above)
            tableView.draggingDestinationFeedbackStyle = .gap
            return .move
        }
        if info.draggingPasteboard.types?.contains(.trigger) == true {
            // We're copying an item from another table view
            tableView.draggingDestinationFeedbackStyle = .regular
            return .copy
        }
        if Self.trigger(fromDroppedOutputTextOn: info.draggingPasteboard) != nil {
            // Selected session output (or other plain text) becomes a new trigger
            tableView.setDropRow(row, dropOperation: .above)
            tableView.draggingDestinationFeedbackStyle = .gap
            return .copy
        }
        return []
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int,
                   dropOperation _: NSTableView.DropOperation) -> Bool {
        let items = info.draggingPasteboard.pasteboardItems ?? []

        if let source = info.draggingSource as? NSTableView, source === tableView {
            // We're moving an item within the same tableview
            let indexes = items.compactMap { $0.pasteboardInteger(forType: .tableViewIndex) }
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

        if let trigger = Self.trigger(fromDroppedOutputTextOn: info.draggingPasteboard),
           let index = insertTrigger(trigger, at: row) {
            tableView.scrollRowToVisible(index)
            return true
        }

        return false
    }

    /// Inserts `trigger` at the proposed drop row and selects it. Returns the index used.
    func insertTrigger(_ trigger: Trigger, at row: Int) -> Int? {
        guard let store else { return nil }
        let index = Self.insertionIndex(proposedRow: row, itemCount: store.state?.triggerList.items.count ?? 0)
        store.dispatch(InsertTriggerAction(trigger: trigger, atIndex: index))
        store.dispatch(SelectTriggerAction(selection: index))
        return index
    }

    static func trigger(fromDroppedOutputTextOn pasteboard: NSPasteboard) -> Trigger? {
        if let text = pasteboard.string(forType: .string) {
            return Trigger.fromDroppedOutputText(text)
        }
        // WebKit selection drags sometimes offer rich text that AppKit can still read as a string.
        let strings = pasteboard.readObjects(forClasses: [NSString.self], options: nil) as? [String]
        guard let text = strings?.first else { return nil }
        return Trigger.fromDroppedOutputText(text)
    }

    static func insertionIndex(proposedRow row: Int, itemCount: Int) -> Int {
        if row < 1 {
            return 0
        }
        if row < itemCount {
            return row
        }
        return itemCount
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
            cell.updateContent(viewModel: viewModel)
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
    func checkableItem(itemID: String, didChangeChecked checked: Bool) {
        guard let triggerID = SavitarObjectID(identifier: itemID)
        else { preconditionFailure("Invalid Trigger identifier \(itemID).") }

        let action: TriggerAction = {
            switch checked {
            case false: return TriggerAction.disable(triggerID)
            case true: return TriggerAction.enable(triggerID)
            }
        }()

        store?.dispatch(action)
    }
}
