//
//  EventsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet var triggerTable: NSOutlineView!
    @IBOutlet var audioCueColumn: NSTableColumn!
    @IBOutlet var enabledColumn: NSTableColumn!
    @IBOutlet var nameColumn: NSTableColumn!
    @IBOutlet var typeColumn: NSTableColumn!

    var triggerMen: [TriggerMan] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        triggerTable.action = #selector(onItemClicked)

        triggerMen.append(AppContext.prefs.triggerMan)
        for world in AppContext.worldMan.get() {
            triggerMen.append(world.triggerMan)
        }
        triggerTable.reloadData()

        for tm in triggerMen {
            triggerTable.expandItem(tm)
        }
    }

    @objc private func onItemClicked() {
        if triggerTable.clickedColumn == 0 {
            let item = triggerTable.item(atRow: triggerTable.clickedRow)
            doUndoableToggle(item: item)
        }
    }

    private func doUndoableToggle(item: Any?) {
        // always register the undo with this window's undo manager.
        undoManager?.registerUndo(withTarget: self, handler: { (_) in
            self.doUndoableToggle(item: item)
        })
        toggleEnabled(item: item)
    }

    private func toggleEnabled(item: Any?) {
        // if the trigger manager has its own undomanager (like in the case of a world document)
        // then inform that undo manager of the change too
        if let triggerMan = triggerTable.parent(forItem: item) as? TriggerMan {
            triggerMan.undoManager?.registerUndo(withTarget: self, handler: { (_) in
                self.toggleEnabled(item: item)
            })
        }

        // now do the actual toggle
        guard let trigger = item as? Trigger else { return }
        if trigger.flags.contains(.disabled) {
            trigger.flags.remove(.disabled)
        } else {
            trigger.flags.insert(.disabled)
        }
        triggerTable.reloadData()
    }

    @IBAction func doubleClickedTrigger(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        if let trigger = item as? Trigger {
            let bundle = Bundle(for: Self.self)
            let storyboard = NSStoryboard(name: "TriggerWindow", bundle: bundle)
            guard let controller = storyboard.instantiateInitialController() as? NSWindowController else {
                return
            }
            guard let triggerWindow = controller.window else {
                return
            }

            // Have the trigger window's view controller get a copy of the trigger
            guard let vc = triggerWindow.contentViewController as? TriggerSettingsController else { return }
            vc.trigger = trigger

            // Open the trigger window modally
            triggerWindow.makeKeyAndOrderFront(self)
            NSApplication.shared.runModal(for: triggerWindow)

            // Run til the window is signaled to close and close the window
            triggerWindow.close()

            // If there are changes to apply, apply them now to the corresponding triggerMan
            if vc.applyChange {
                if let triggerMan = sender.parent(forItem: item) as? TriggerMan {
                    triggerMan.set(index: sender.childIndex(forItem: item!), object: vc.trigger!)
                    triggerTable.reloadData()
                }
            }
        }
    }

    // MARK: - NSOutlineViewDataSource

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let man = item as? ModelManager {
            return man.get().count
        }
        return triggerMen.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let man = item as? ModelManager {
            return man.get()[index]
        }

        return triggerMen[index]
    }

    // MARK: - NSOutlineViewDelegate

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let man = item as? ModelManager {
            return man.get().count > 0
        }

        return false
    }

    func outlineView(_ outlineVIew: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return !(item is ModelManager)
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let cell = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
            as? NSTableCellView else { return nil }
        guard let textField = cell.textField else { return nil }

        if let triggerMan = item as? TriggerMan {
            if tableColumn! == nameColumn {
                textField.stringValue = triggerMan.name
            } else {
                textField.stringValue = ""
            }
        } else if let trigger = item as? Trigger {
            switch tableColumn {
            case enabledColumn:
                textField.stringValue = trigger.flags.contains(.disabled) ? "x" : "√"
            case nameColumn:
                textField.stringValue = trigger.name
            case typeColumn:
                if let value = trigger.typeDict[trigger.type] {
                    textField.stringValue = value
                }
            case audioCueColumn:
                if let value = trigger.audioCueDict[trigger.audioCue] {
                    textField.stringValue = value
                }
            default:
                print("Skipping \((tableColumn?.identifier)!.rawValue) column")
            }
        }

        return cell
    }
 }
