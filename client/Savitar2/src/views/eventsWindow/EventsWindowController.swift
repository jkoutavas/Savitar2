//
//  EventsWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Universal and per-world Events utility window chrome ([HIG.md](../../../docs/HIG.md) — Events window; Story 6).
final class EventsWindowController: NSWindowController, NSWindowDelegate {
    static let designedContentSize = NSSize(width: 900, height: 400)

    var reactionsStore: ReactionsStore? {
        didSet {
            if let content = contentViewController as? EventsContentViewController {
                content.store = reactionsStore
            }
        }
    }

    var onWillClose: ((_ isTerminating: Bool) -> Void)?
    var undoManagerProvider: (() -> UndoManager?)?

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window else { return }

        window.configureAsSettingsWindow(delegate: self)
        window.isReleasedWhenClosed = false
        applyDesignedContentSize()
    }

    func present(autosaveName: String, title: String) {
        window?.title = title
        windowFrameAutosaveName = autosaveName
        applyDesignedContentSize()
        if !NSWindow.hasAutosavedFrame(named: autosaveName) {
            window?.center()
        }
        showWindow(self)
    }

    private func applyDesignedContentSize() {
        guard let window else { return }
        window.fitContentSize(Self.designedContentSize, centerIfNeeded: false)
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        undoManagerProvider?()
    }

    func windowWillClose(_: Notification) {
        onWillClose?(AppContext.shared.isTerminating)
    }
}
