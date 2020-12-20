//
//  MacroTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

typealias MacroListViewModel = ListViewModel<MacroViewModel>

class MacroTableDataSource: NSObject, ReactionsStoreSetter {
    var listModel: MacroListViewModel?
    var store: ReactionsStore?
}

extension MacroTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return listModel?.itemCount ?? 0
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let viewModel = listModel?.viewModels[safe: row] else { return nil }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier) else { return nil }
        guard let object = store?.state?.macroList.item(objectID: objID) else { return nil }
        return MacroPasteboardWriter(object: object, at: row)
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
                store?.dispatch(MoveMacroAction(from: indexes[0], to: row))
                return true
            }
        } else {
            // We're copying an item from another table view
            let macros = items.compactMap { $0.string(forType: .macro) }
            if !macros.isEmpty {
                do {
                    let xml = try XML.parse(macros[0])
                    let elem = xml[MacroElemIdentifier]
                    if case .failure = elem {
                        return false
                    }
                    let macro = Macro()
                    try macro.parse(xml: elem)
                    store?.dispatch(InsertMacroAction(macro: macro, atIndex: row))
                    return true
                } catch {
                    return false
                }
            }
        }
        return false
    }
}

extension MacroTableDataSource: ItemTableDataSourceType {
    var selectedRow: Int? { return listModel?.selectedRow }
    var selectedItem: MacroViewModel? { return listModel?.selectedItem }
    var itemCount: Int { return listModel?.itemCount ?? 0 }

    func getStore() -> ReactionsStore? {
        return store
    }

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    func updateContents(listModel: MacroListViewModel) {
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
            setTextField(cell, viewModel.hotKey)
            return cell

        case tableView.tableColumns[2]:
            guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView else { return nil }
            setTextField(cell, viewModel.value)
            return cell

        default:
            return nil
        }
    }
}

extension MacroTableDataSource: CheckableItemChangeDelegate {
    func checkableItem(identifier: String, didChangeChecked checked: Bool) {
        guard let macroID = SavitarObjectID(identifier: identifier)
            else { preconditionFailure("Invalid macro identifier \(identifier).") }

        let action: MacroAction = {
            switch checked {
            case false: return MacroAction.disable(macroID)
            case true: return MacroAction.enable(macroID)
            }
        }()

        store?.dispatch(action)
    }
}
