//
//  EventsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var triggerTable: NSTableView!

    func numberOfRows(in tableView: NSTableView) -> Int {
        return AppContext.triggerMan.get().count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      let trigger = AppContext.triggerMan.get()[row]

      guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
        as? NSTableCellView else { return nil }

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

      return cell
    }
}
