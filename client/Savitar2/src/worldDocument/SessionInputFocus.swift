//
//  SessionInputFocus.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import AppKit

/// Policy for when the session input line should reclaim first responder from
/// the output pane (or a stale responder left behind by Services / backgrounding).
enum SessionInputFocus {
    /// Printable typing without Cmd/Ctrl — reclaim input so the caret returns.
    /// Leaves menu shortcuts (Copy, Paste, Find, etc.) alone while output is focused.
    static func shouldReclaimForTyping(modifierFlags: NSEvent.ModifierFlags, characters: String?) -> Bool {
        let flags = modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.command) || flags.contains(.control) {
            return false
        }
        guard let characters, !characters.isEmpty else { return false }
        return true
    }
}
