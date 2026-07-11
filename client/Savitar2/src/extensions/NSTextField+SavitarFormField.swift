//
//  NSTextField+SavitarFormField.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

extension NSTextField {
    /// Standard bordered editable field for Settings / Events detail panes (readable in light and dark mode).
    func applySavitarFormFieldStyle() {
        isBordered = true
        isBezeled = true
        bezelStyle = .squareBezel
        drawsBackground = true
        backgroundColor = .textBackgroundColor
        focusRingType = .default
        cell?.isBezeled = true
        cell?.isBordered = true
    }
}
