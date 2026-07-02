//
//  TerminalBell.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import AppKit

enum TerminalBell {
    static let character: Character = "\u{7}"

    static var playSound: () -> Void = { NSSound.beep() }

    static func process(_ text: String, muted: Bool) -> String {
        guard text.contains(character) else { return text }

        var result = ""
        for char in text {
            if char == character {
                if !muted {
                    playSound()
                }
            } else {
                result.append(char)
            }
        }
        return result
    }
}
