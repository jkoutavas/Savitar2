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

    let triggerMen = [AppContext.prefs.triggerMan, TriggerMan.init()]

    override func viewDidLoad() {
        super.viewDidLoad()
        triggerMen[1].name = "foo"
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
        if item is Trigger {
            print("heynow")
        }
    }
 }
