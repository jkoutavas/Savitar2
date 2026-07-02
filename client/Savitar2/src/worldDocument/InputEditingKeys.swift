//
//  InputEditingKeys.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

enum InputEditingKeys {
    enum Action: Equatable {
        case moveLeft
        case moveRight
        case beginningOfLine
        case sendInterrupt
        case sendBell
    }

    static let interruptCharacter = "\u{3}"
    static let bellCharacter = "\u{7}"

    static func action(for event: NSEvent) -> Action? {
        let flags = HotKey.normalize(modifierFlags: event.modifierFlags)

        switch event.keyCode {
        case Keycode.leftArrow where flags.isEmpty:
            return .moveLeft
        case Keycode.rightArrow where flags.isEmpty:
            return .moveRight
        case Keycode.a where flags == .control:
            return .beginningOfLine
        case Keycode.c where flags == .control:
            return .sendInterrupt
        case Keycode.g where flags == .control:
            return .sendBell
        default:
            return nil
        }
    }
}
