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
            if let macro = liveMacros(for: session).first(where: { $0.name == trimmed }) {
                return macro
            }
        }

        return AppContext.shared.universalReactionsStore.state?.macroList.items
            .first(where: { $0.name == trimmed })
    }

    /// Live macros from the world's Events store when available; otherwise persisted `macroMan`.
    private static func liveMacros(for session: Session) -> [Macro] {
        if let document = session.sessionHandler as? Document,
           let macros = document.store.state?.macroList.items {
            return macros
        }
        for window in NSApp.orderedWindows {
            guard let windowController = window.windowController as? WindowController,
                  let sessionViewController = windowController.contentViewController as? SessionViewController,
                  sessionViewController.session === session,
                  let document = windowController.document as? Document,
                  let macros = document.store.state?.macroList.items
            else { continue }
            return macros
        }
        return session.world.macroMan.get()
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
        if let windowController = window.windowController as? WindowController {
            return (windowController.contentViewController as? SessionViewController)?.session
        }
        if let eventsWindowController = window.windowController as? EventsWindowController {
            return eventsWindowController.owningSession
        }
        return nil
    }
}
