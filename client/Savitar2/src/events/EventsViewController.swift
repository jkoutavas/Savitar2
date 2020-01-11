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

    var triggerMen: [TriggerMan] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        triggerMen.append(AppContext.prefs.triggerMan)
        for world in AppContext.worldMan.get() {
            triggerMen.append(world.triggerMan)
        }
        triggerTable.reloadData()

        for tm in triggerMen {
            triggerTable.expandItem(tm)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let triggerMan = item as? TriggerMan {
            return triggerMan.get().count
        }
        return triggerMen.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let triggerMan = item as? TriggerMan {
            return triggerMan.get()[index]
        }

        return triggerMen[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let triggerMan = item as? TriggerMan {
            return triggerMan.get().count > 0
        }

        return false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let cell = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
            as? NSTableCellView else { return nil }

        if let triggerMan = item as? TriggerMan {
            if tableColumn!.identifier.rawValue == "name" {
                cell.textField?.stringValue = triggerMan.name
            } else {
                cell.textField?.stringValue = ""
            }
        } else if let trigger = item as? Trigger {
            if (tableColumn?.identifier)!.rawValue == "name" {
                cell.textField?.stringValue = trigger.name
            } else if (tableColumn?.identifier)!.rawValue == "type" {
              if let value = trigger.typeDict[trigger.type] {
                  cell.textField?.stringValue = value
              }
            } else {
                if let value = trigger.audioCueDict[trigger.audioCue] {
                    cell.textField?.stringValue = value
                }
            }
        }

        return cell
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
 }
