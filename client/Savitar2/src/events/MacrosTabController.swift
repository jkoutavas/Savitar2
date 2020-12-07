//
//  MacrosTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

protocol MacroTableDataSourceType {
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedMacro: MacroViewModel? { get }
    var macroCount: Int { get }

    func updateContents(macrosViewModel viewModel: MacrosViewModel)
    func getStore() -> ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?)
    func macroCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

class MacrosTabController: EventsTabController {
    private var dataSource: MacroTableDataSourceType = MacroTableDataSource()
    private var selectionIsChanging = false

    override func setStore(reactionsStore: ReactionsStore?) {
        dataSource.setStore(reactionsStore: store)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
        tableView.registerForDraggedTypes([.macro, .tableViewIndex])
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }
}

extension MacrosTabController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return dataSource.selectedMacro != nil
        }
        return true
    }

    @IBAction func delete(_ sender: AnyObject) {
        guard let viewModel = dataSource.selectedMacro else { return }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier ) else { return }
        store?.dispatch(RemoveMacroAction(macroID: objID))
    }
}

extension MacrosTabController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return dataSource.macroCellView(tableView, viewFor: tableColumn, row: row)
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
    func displayMacros(macrosViewModel viewModel: MacrosViewModel) {
        updateTableDataSource(viewModel: viewModel)

        selectionIsChanging = true
        displaySelection(viewModel: viewModel)
        selectionIsChanging = false
    }

    fileprivate func updateTableDataSource(viewModel: MacrosViewModel) {
        dataSource.updateContents(macrosViewModel: viewModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(viewModel: MacrosViewModel) {
        guard let selectedRow = viewModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }
}

extension MacrosTabController: StoreSubscriber {
    func newState(state: ReactionsState) {
        let macroViewModels = state.macroList.items.map(MacroViewModel.init)
        let macrosViewModel = MacrosViewModel(
            macros: macroViewModels,
            selectedRow: state.macroList.selection
        )

        displayMacros(macrosViewModel: macrosViewModel)
    }
}
