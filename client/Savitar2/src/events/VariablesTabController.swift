//
//  VariablesTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

protocol VariableTableDataSourceType {
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedVariable: VariableViewModel? { get }
    var variableCount: Int { get }

    func updateContents(variablesViewModel viewModel: VariablesViewModel)
    func getStore() -> ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?)
    func variableCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

class VariablesTabController: EventsTabController {

    var dataSource: VariableTableDataSourceType = VariableTableDataSource() {
        didSet {
            tableView.dataSource = dataSource.tableDataSource
        }
    }

    private var selectionIsChanging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
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

extension VariablesTabController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return dataSource.variableCellView(tableView, viewFor: tableColumn, row: row)
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

        store?.dispatch(SelectVariableAction(selection: sel))
    }
}

extension VariablesTabController {
    func displayVariables(variablesViewModel viewModel: VariablesViewModel) {
        updateTableDataSource(viewModel: viewModel)

        selectionIsChanging = true
        displaySelection(viewModel: viewModel)
        selectionIsChanging = false

        focusTableView()
    }

    fileprivate func updateTableDataSource(viewModel: VariablesViewModel) {
        dataSource.updateContents(variablesViewModel: viewModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(viewModel: VariablesViewModel) {
        guard let selectedRow = viewModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }

    fileprivate func focusTableView() {
        view.window?.makeFirstResponder(tableView)
    }
}

extension VariablesTabController: StoreSubscriber {
    func newState(state: ReactionsState) {
        let variableViewModels = state.variableList.items.map(VariableViewModel.init)
        let variablesViewModel = VariablesViewModel(
            variables: variableViewModels,
            selectedRow: state.variableList.selection
        )

        displayVariables(variablesViewModel: variablesViewModel)
    }
}
