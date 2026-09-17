//
//  EventsWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Universal and per-world Events utility window chrome ([HIG.md](../../../docs/HIG.md) — Events window; Story 6).
final class EventsWindowController: NSWindowController, NSWindowDelegate {
    static let windowWidth: CGFloat = 900
    static let triggersContentHeight: CGFloat = 480
    static let macrosContentHeight: CGFloat = 400
    static let designedContentSize = NSSize(width: windowWidth, height: triggersContentHeight)

    var reactionsStore: ReactionsStore? {
        didSet {
            if let content = contentViewController as? EventsContentViewController {
                content.store = reactionsStore
            }
        }
    }

    var onWillClose: ((_ isTerminating: Bool) -> Void)?
    var undoManagerProvider: (() -> UndoManager?)?
    weak var owningSession: Session?

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
        updateForSelectedTab(animated: false)
        if !NSWindow.hasAutosavedFrame(named: autosaveName) {
            window?.center()
        }
        showWindow(self)
    }

    func updateForSelectedTab(animated: Bool) {
        let tabIndex = eventsTabIndex
        let height = tabIndex == 1 ? Self.macrosContentHeight : Self.triggersContentHeight
        applyLockedContentSize(NSSize(width: Self.windowWidth, height: height), animate: animated)
    }

    private var eventsTabIndex: Int {
        let content = contentViewController as? EventsContentViewController
        return content?.eventsViewController?.selectedTabViewItemIndex ?? 0
    }

    private func applyDesignedContentSize() {
        updateForSelectedTab(animated: false)
    }

    private func applyLockedContentSize(_ size: NSSize, animate: Bool) {
        guard let window else { return }
        window.contentMinSize = NSSize(width: 1, height: 1)
        window.contentMaxSize = NSSize(width: 10_000, height: 10_000)
        window.setContentSizeKeepingTitleBar(size, animate: animate)
        window.contentMinSize = size
        window.contentMaxSize = size
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        undoManagerProvider?()
    }

    func windowWillClose(_: Notification) {
        onWillClose?(AppContext.shared.isTerminating)
    }
}
