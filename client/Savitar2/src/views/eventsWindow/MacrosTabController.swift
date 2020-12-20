//
//  MacrosTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class MacrosTabController: EventsTabController {
    private var dataSource = MacroTableDataSource()
    private var subscriber: MacrosSubscriber<ItemListState<Macro>>?
    private var selectionIsChanging = false

    override func setStore(_ store: ReactionsStore?) {
        dataSource.setStore(store)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
        tableView.registerForDraggedTypes([.macro, .tableViewIndex])
        subscriber = MacrosSubscriber<ItemListState<Macro>>(self)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(subscriber!) {
            $0.select { $0.macroList }
        }

        if let window = view.window {
            window.makeFirstResponder(view) // useful for selection state
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(subscriber!)
    }
}

extension MacrosTabController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return dataSource.selectedItem != nil
        }
        return true
    }

    @IBAction func delete(_ sender: AnyObject) {
        guard let viewModel = dataSource.selectedItem else { return }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier ) else { return }
        store?.dispatch(RemoveMacroAction(macroID: objID))
    }
}

extension MacrosTabController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return dataSource.itemCellView(tableView, viewFor: tableColumn, row: row)
    }

    func tableViewSelectionDidChange(_: Notification) {
        if selectionIsChanging {
            return
        }

        let sel: SelectionState = {
            // "None" equals -1
            guard tableView.selectedRow >= 0 else { return nil }

            return tableView.selectedRow
        }()

        store?.dispatch(SelectMacroAction(selection: sel))
    }
}

extension MacrosTabController {
    func displayList(listModel: MacroListViewModel) {
        updateTableDataSource(listModel: listModel)

        selectionIsChanging = true
        displaySelection(listModel: listModel)
        selectionIsChanging = false
    }

    fileprivate func updateTableDataSource(listModel: MacroListViewModel) {
        dataSource.updateContents(listModel: listModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(listModel: MacroListViewModel) {
        guard let selectedRow = listModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }
}

class MacrosSubscriber<T>: StoreSubscriber {
    var tableController: MacrosTabController?

    init(_ tableController: MacrosTabController) {
        self.tableController = tableController
    }

    func newState(state: ItemListState<Macro>) {
        let viewModels = state.items.map(MacroViewModel.init)
        let listModel = MacroListViewModel(
            viewModels: viewModels,
            selectedRow: state.selection
        )

        tableController?.displayList(listModel: listModel)
    }
}
