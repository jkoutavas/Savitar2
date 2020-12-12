//
//  MacroTableDataSource.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

class MacroTableDataSource: NSObject, ReactionStoreSetter {
    var viewModel: MacrosViewModel?
    var store: ReactionsStore?
}

extension MacroTableDataSource: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return viewModel?.itemCount ?? 0
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let viewModel = viewModel?.macros[safe: row] else { return nil }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier) else { return nil }
        guard let object = store?.state?.macroList.item(objectID: objID) else { return nil }
        return SavitarObjectPasteboardWriter(object: object, at: row)
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

extension MacroTableDataSourceType where Self: NSTableViewDataSource {
    var tableDataSource: NSTableViewDataSource {
        return self
    }
}

extension MacroTableDataSource: MacroTableDataSourceType {
    var selectedRow: Int? { return viewModel?.selectedRow }
    var selectedMacro: MacroViewModel? { return viewModel?.selectedMacro }
    var macroCount: Int { return viewModel?.itemCount ?? 0 }

    func getStore() -> ReactionsStore? {
        return store
    }

    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
    }

    func updateContents(macrosViewModel viewModel: MacrosViewModel) {
        self.viewModel = viewModel
    }

    func macroCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        func setTextField(_ cell: NSTableCellView, _ value: String) {
            guard let textField = cell.textField else { return }
            textField.stringValue = value
        }
        guard let vViewModel = viewModel?.macros[row] else { return nil }
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
