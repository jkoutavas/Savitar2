//
//  MacroClicker.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Macro Clicker send path and macro resolution (Story 11).
enum MacroClicker {
    static let undefinedCaption = "Button not defined"

    /// Frontmost connected world session (v1 `UDesktop::FetchTopRegular` / `Wind_WorldText`).
    static func frontmostSession() -> Session? {
        for window in NSApp.orderedWindows where window.isVisible && !window.isMiniaturized {
            if let session = session(in: window) {
                return session
            }
        }
        return nil
    }

    static func resolvedMacro(named name: String, session: Session?) -> Macro? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let session {
            if let macro = session.world.macroMan.get().first(where: { $0.name == trimmed }) {
                return macro
            }
        }

        return AppContext.shared.universalReactionsStore.state?.macroList.items
            .first(where: { $0.name == trimmed })
    }

    static func caption(for macroName: String, session: Session?) -> String {
        guard let macro = resolvedMacro(named: macroName, session: session) else {
            return undefinedCaption
        }
        let value = macro.value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? undefinedCaption : value
    }

    static func playClickSound() {
        guard !AppContext.shared.prefs.flags.contains(.muteClicker) else { return }
        NSSound(named: NSSound.Name("Click"))?.play()
    }

    static func sendMacro(named name: String) {
        guard let session = frontmostSession() else { return }
        guard let macro = resolvedMacro(named: name, session: session), macro.enabled else { return }

        let value = macro.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        playClickSound()
        session.submitServerCmd(cmd: Command(text: value))
    }

    private static func session(in window: NSWindow) -> Session? {
        guard let windowController = window.windowController as? WindowController else { return nil }
        return (windowController.contentViewController as? SessionViewController)?.session
    }
}
