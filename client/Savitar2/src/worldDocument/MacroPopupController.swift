//
//  MacroPopupController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//
//  Savitar 1.x origin:
//  File:     CTVVarPopup.cp
//  Purpose: Macro/variable type-ahead while typing in the input pane
//

import Foundation

/// Type-ahead against macro names while typing in the session input pane (v1 `CTVVarPopup`).
final class MacroPopupController {
    static let matchCount = 3
    static let maxTooltipLength = 40

    enum Mode: Equatable {
        case interested
        case showing
        case dismissed
    }

    enum Key: Equatable {
        case `return`
        case backspace
        case space
        case character(Character)
        case invalid
    }

    enum DisplayUpdate: Equatable {
        case show(value: String, blink: Bool)
        case hide
    }

    enum Action: Equatable {
        case none
        /// Return while showing: replace the typed prefix with the macro value (do not submit).
        case accept(value: String, replaceLength: Int)
        case update(DisplayUpdate)
    }

    private(set) var mode: Mode = .interested
    private(set) var buffer = ""
    private var candidates: [Macro] = []

    var bufferLength: Int { buffer.count }

    func reset() {
        mode = .interested
        buffer = ""
        candidates = []
    }

    /// Truncate macro value for the tooltip (v1 40 chars + ellipsis).
    static func tooltipText(for value: String) -> String {
        guard value.count > maxTooltipLength else { return value }
        return String(value.prefix(maxTooltipLength)) + "…"
    }

    /// Map an AppKit key event into a popup key (return / delete / space / identifier / invalid).
    static func key(fromEventKeyCode keyCode: UInt16, characters: String?) -> Key {
        switch keyCode {
        case Keycode.returnKey:
            return .return
        case Keycode.delete:
            return .backspace
        case Keycode.space:
            return .space
        default:
            guard let characters, characters.count == 1, let char = characters.first else {
                return .invalid
            }
            if VariableMan.isValidVariableCharacter(char) {
                return .character(char)
            }
            return .invalid
        }
    }

    /// Process a key. `allMacros` supplies world-then-universal macros when rebuilding the candidate list.
    func handle(key: Key, allMacros: () -> [Macro]) -> Action {
        switch key {
        case .return:
            guard mode == .showing, let match = candidates.first else {
                reset()
                return .update(.hide)
            }
            let value = match.value
            let replaceLength = buffer.count
            reset()
            return .accept(value: value, replaceLength: replaceLength)

        case .backspace:
            guard mode != .dismissed, !buffer.isEmpty else {
                return .none
            }
            buffer.removeLast()
            rebuildCandidates(from: allMacros())
            lookup()
            if buffer.isEmpty {
                mode = .interested
                return .update(.hide)
            }
            return displayAction()

        case .space:
            reset()
            return .update(.hide)

        case .character(let char):
            guard mode != .dismissed else {
                return .none
            }
            buffer.append(char)
            if buffer.count == 1 {
                rebuildCandidates(from: allMacros())
            }
            lookup()
            return displayAction()

        case .invalid:
            reset()
            return .update(.hide)
        }
    }

    // MARK: - Private (v1 MakeVarList / Lookup)

    private func rebuildCandidates(from macros: [Macro]) {
        candidates = macros.filter { $0.name.hasPrefix(buffer) }
    }

    private func lookup() {
        if !buffer.isEmpty {
            candidates = candidates.filter { $0.name.hasPrefix(buffer) }
        }

        if !candidates.isEmpty {
            if buffer.count >= Self.matchCount {
                mode = .showing
            } else if mode == .showing {
                mode = .interested
            }
        } else if mode == .showing {
            mode = .dismissed
        }
    }

    private func displayAction() -> Action {
        switch mode {
        case .showing:
            guard let match = candidates.first else {
                return .update(.hide)
            }
            let blink = buffer.count == match.name.count
            return .update(.show(value: Self.tooltipText(for: match.value), blink: blink))
        case .interested, .dismissed:
            return .update(.hide)
        }
    }
}
