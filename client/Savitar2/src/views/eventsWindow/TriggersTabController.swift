//
//  TriggersTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggersTabController: EventsTabController {
    private var dataSource = TriggerTableDataSource()
    private var subscriber: TriggersSubscriber<ItemListState<Trigger>>?
    private var selectionIsChanging = false

    override func setStore(_ store: ReactionsStore?) {
        dataSource.setStore(store)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
        tableView.registerForDraggedTypes([.trigger, .tableViewIndex])
        subscriber = TriggersSubscriber<ItemListState<Trigger>>(self)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(subscriber!) {
            $0.select { $0.triggerList }
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

extension TriggersTabController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return dataSource.selectedItem != nil
        }
        return true
    }

    @IBAction func delete(_ sender: AnyObject) {
        guard let viewModel = dataSource.selectedItem else { return }
        guard let objID = SavitarObjectID(identifier: viewModel.identifier ) else { return }
        store?.dispatch(RemoveTriggerAction(triggerID: objID))
    }
}

extension TriggersTabController: NSTableViewDelegate {
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

        store?.dispatch(SelectTriggerAction(selection: sel))
    }
}

extension TriggersTabController {
    func displayList(listModel: TriggerListViewModel) {
        updateTableDataSource(listModel: listModel)

        selectionIsChanging = true
        displaySelection(listModel: listModel)
        selectionIsChanging = false
    }

    fileprivate func updateTableDataSource(listModel: TriggerListViewModel) {
        dataSource.updateContents(listModel: listModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(listModel: TriggerListViewModel) {
        guard let selectedRow = listModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }
}

class TriggersSubscriber<T>: StoreSubscriber {
    var tableController: TriggersTabController?

    init(_ tableController: TriggersTabController) {
        self.tableController = tableController
    }

    func newState(state: ItemListState<Trigger>) {
        let viewModels = state.items.map(TriggerViewModel.init)
        let listModel = TriggerListViewModel(
            viewModels: viewModels,
            selectedRow: state.selection
        )

        tableController?.displayList(listModel: listModel)
    }
}

class ItemsSubscriber<T>: StoreSubscriber {
    var tableController: TriggersTabController?

    init(_ tableController: TriggersTabController) {
        self.tableController = tableController
    }

    func newState(state: ItemListState<Trigger>) {
        let viewModels = state.items.map(TriggerViewModel.init)
        let listModel = TriggerListViewModel(
            viewModels: viewModels,
            selectedRow: state.selection
        )

        tableController?.displayList(listModel: listModel)
    }
}
