//
//  EventsWindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/14/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsWindowController: NSWindowController {
    // https://stackoverflow.com/a/62919856/246887
    override func windowDidLoad() {
        super.windowDidLoad()
        self.windowFrameAutosaveName = "EventsWindowFrame"
    }
}
