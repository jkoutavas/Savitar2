//
//  TriggersTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

protocol TriggerTableDataSourceType {
    var tableDataSource: NSTableViewDataSource { get }

    var selectedRow: SelectionState { get }
    var selectedTrigger: TriggerViewModel? { get }
    var triggerCount: Int { get }

    func updateContents(triggersViewModel viewModel: TriggersViewModel)
    func getStore() -> ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?)
    func triggerCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

class TriggersTabController: EventsTabController {
    private var dataSource: TriggerTableDataSourceType = TriggerTableDataSource()
    private var selectionIsChanging = false

    override func setStore(reactionsStore: ReactionsStore?) {
        dataSource.setStore(reactionsStore: store)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
        tableView.registerForDraggedTypes([.trigger, .tableViewIndex])
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

extension TriggersTabController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return dataSource.selectedTrigger != nil
        }
        return true
    }

    @IBAction func delete(_ sender: AnyObject) {
        guard let viewModel = dataSource.selectedTrigger else { return }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier ) else { return }
        store?.dispatch(RemoveTriggerAction(triggerID: objID))
    }
}

extension TriggersTabController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return dataSource.triggerCellView(tableView, viewFor: tableColumn, row: row)
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

        store?.dispatch(SelectTriggerAction(selection: sel))
    }
}

extension TriggersTabController {
    func displayTriggers(triggersViewModel viewModel: TriggersViewModel) {
        updateTableDataSource(viewModel: viewModel)

        selectionIsChanging = true
        displaySelection(viewModel: viewModel)
        selectionIsChanging = false
    }

    fileprivate func updateTableDataSource(viewModel: TriggersViewModel) {
        dataSource.updateContents(triggersViewModel: viewModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(viewModel: TriggersViewModel) {
        guard let selectedRow = viewModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }
}

extension TriggersTabController: StoreSubscriber {
    func newState(state: ReactionsState) {
        let triggerViewModels = state.triggerList.items.map(TriggerViewModel.init)
        let triggersViewModel = TriggersViewModel(
            triggers: triggerViewModels,
            selectedRow: state.triggerList.selection
        )

        displayTriggers(triggersViewModel: triggersViewModel)
    }
}
