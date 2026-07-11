//
//  HotKeyField.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Single-line hotkey capture field for the Macros detail pane (press a key to assign; display via `stringValue`).
final class HotKeyField: NSTextField {
    var completionHandler: ((HotKey) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        isEditable = false
        isSelectable = true
    }

    override func keyDown(with event: NSEvent) {
        completionHandler?(HotKey(event: event))
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }
}
