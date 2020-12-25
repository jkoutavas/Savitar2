//
//  WorldPickerController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

extension Document {
    func loadAndShow(world: World) {
        version = 2
        self.world = world
        makeWindowControllers()
        showWindows()
    }
}

class WorldPickerController: NSViewController, WorldsStoreSetter {
    var store: WorldsStore?
    private var dataSource = WorldTableDataSource()
    private var subscriber: WorldsSubscriber<ItemListState<World>>?
    private var selectionIsChanging = false

    @IBOutlet weak var tableView: NSTableView!

    @objc dynamic var world: World?
    @objc dynamic var worldIsSelected = false

    func setStore(_ store: WorldsStore?) {
        dataSource.setStore(store)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource.tableDataSource
        tableView.delegate = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleAction)

        subscriber = WorldsSubscriber<ItemListState<World>>(self)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(subscriber!) {
            $0.select { $0.worldList }
        }

        view.window?.makeFirstResponder(tableView)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(subscriber!)
    }

    @objc func tableViewDoubleAction(sender: AnyObject) {
        if let world = self.world {
            do {
                let document = try NSDocumentController.shared.makeUntitledDocument(ofType: DocumentV2.FileType)
                if let worldDocument = document as? Document {
                    worldDocument.loadAndShow(world: world)
                }
            } catch {}
        }
    }

    @IBAction func addAction(_ sender: Any) {
        let bundle = Bundle(for: Self.self)
        let wizardStoryboard = NSStoryboard(name: "WorldWizard", bundle: bundle)

        guard let wc = wizardStoryboard.instantiateInitialController() as? NSWindowController else { return }
        guard let vc = wc.window?.contentViewController as? WorldWizardController else { return }
        vc.completionHandler = { apply, newWorld in
 //           self.view.window?.makeKeyAndOrderFront(self)
            if apply == true {
                let rows = self.dataSource.listModel?.itemCount ?? 0
                let row = self.tableView.selectedRow >= 0 ? self.tableView.selectedRow + 1 : rows
                self.store?.dispatch(InsertWorldAction(world: newWorld!, atIndex: row))
                let sel: SelectionState = { return row }()
                self.store?.dispatch(SelectWorldAction(selection: sel))
                self.tableView.scrollRowToVisible(row)
            }
        }
        wc.showWindow(self)
    }

    @IBAction func connectAction(_ sender: AnyObject) {
        tableViewDoubleAction(sender: sender)
    }
}

// TODO: candidate for base class (just pass in the remove action)
extension WorldPickerController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return dataSource.selectedItem != nil
        }
        return true
    }

    @IBAction func delete(_ sender: AnyObject) {
        guard let viewModel = dataSource.selectedItem else { return }
        guard let objID = SavitarObjectID(identifier: viewModel.itemID ) else { return }
        store?.dispatch(RemoveWorldAction(worldID: objID))
    }
}

// TODO: candidate for base class (just pass in the selection action)
extension WorldPickerController: NSTableViewDelegate {
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

        store?.dispatch(SelectWorldAction(selection: sel))
    }
}

extension WorldPickerController {
    func displayList(listModel: WorldListViewModel) {
        updateTableDataSource(listModel: listModel)

        selectionIsChanging = true
        displaySelection(listModel: listModel)
        selectionIsChanging = false
    }

    fileprivate func updateTableDataSource(listModel: WorldListViewModel) {
        dataSource.updateContents(listModel: listModel)
        tableView.reloadData()
    }

    fileprivate func displaySelection(listModel: WorldListViewModel) {
        guard let selectedRow = listModel.selectedRow else {
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }
}

class WorldsSubscriber<T>: StoreSubscriber {
    var tableController: WorldPickerController?

    init(_ tableController: WorldPickerController) {
        self.tableController = tableController
    }

    func newState(state: ItemListState<World>) {
        let viewModels = state.items.map(WorldViewModel.init)
        let listModel = WorldListViewModel(
            viewModels: viewModels,
            selectedRow: state.selection
        )

        if let index = state.selection, index < state.items.count {
            tableController?.world = state.items[index]
            tableController?.worldIsSelected = true
        } else {
            tableController?.world = nil
            tableController?.worldIsSelected = false
        }

        tableController?.displayList(listModel: listModel)
    }
}
