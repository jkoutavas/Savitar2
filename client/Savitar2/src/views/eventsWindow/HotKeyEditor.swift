//
//  HotKeyEditor.swift
//  Savitar2
//
//  Created by Jay Koutavas on 7/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class HotKeyEditor: NSTextView {
    var completionHandler: ((HotKey) -> Void)?

    override func keyDown(with event: NSEvent) {
        if let handler = completionHandler {
            handler(HotKey(event: event))
        }
    }
}
