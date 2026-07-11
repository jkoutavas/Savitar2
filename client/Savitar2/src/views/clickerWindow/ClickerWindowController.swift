//
//  ClickerWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Macro Clicker utility window chrome ([HIG.md](../../../docs/HIG.md); Story 11).
final class ClickerWindowController: NSWindowController, NSWindowDelegate {
    static let windowTitle = "Macro Clicker"

    /// Legacy AppKit frame autosave key — cleared on load so an old oversized frame cannot stick.
    static let legacyFrameAutosaveName = "MacroClickerFrame"
    private static let positionAutosaveKey = "MacroClickerOrigin"

    var onWillClose: ((_ isTerminating: Bool) -> Void)?

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window else { return }

        window.configureAsSettingsWindow(delegate: self)
        window.title = Self.windowTitle
        window.isReleasedWhenClosed = false
        window.titleVisibility = .visible
        window.hidesOnDeactivate = false
        clearLegacyAutosavedFrame()
        applyDesignedContentSize()
        installKeyWindowObserver()
    }

    deinit {
        if let keyWindowObserver {
            NotificationCenter.default.removeObserver(keyWindowObserver)
        }
    }

    private var keyWindowObserver: NSObjectProtocol?

    private func installKeyWindowObserver() {
        keyWindowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, let window, window.isVisible else { return }
            (contentViewController as? ClickerContentViewController)?.redisplayPalette()
        }
    }

    func present() {
        loadWindow()
        window?.title = Self.windowTitle
        clearLegacyAutosavedFrame()
        applyDesignedContentSize()
        if let origin = Self.savedOrigin() {
            window?.setFrameOrigin(origin)
        } else {
            window?.center()
        }
        showWindow(self)
        window?.orderFrontRegardless()
    }

    func applyDesignedContentSize() {
        guard let window else { return }
        let designed = ClickerContentViewController.designedContentSize
        let origin = window.frame.origin
        window.fitContentSize(designed, centerIfNeeded: false)
        window.setFrameOrigin(origin)
    }

    func windowWillClose(_: Notification) {
        onWillClose?(AppContext.shared.isTerminating)
    }

    func windowDidMove(_: Notification) {
        saveOrigin()
    }

    private func saveOrigin() {
        guard let window else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set(NSStringFromPoint(origin), forKey: Self.positionAutosaveKey)
    }

    private static func savedOrigin() -> NSPoint? {
        guard let string = UserDefaults.standard.string(forKey: positionAutosaveKey) else { return nil }
        let origin = NSPointFromString(string)
        return isOriginOnVisibleScreen(origin) ? origin : nil
    }

    private static func isOriginOnVisibleScreen(_ origin: NSPoint) -> Bool {
        let probe = NSRect(
            origin: origin,
            size: ClickerContentViewController.designedContentSize
        )
        return NSScreen.screens.contains { $0.visibleFrame.intersects(probe) }
    }

    private func clearLegacyAutosavedFrame() {
        let defaults = UserDefaults.standard
        let prefix = "NSWindow Frame \(Self.legacyFrameAutosaveName)"
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
        windowFrameAutosaveName = ""
    }

    static func clearSavedPosition() {
        UserDefaults.standard.removeObject(forKey: positionAutosaveKey)
        let defaults = UserDefaults.standard
        let prefix = "NSWindow Frame \(legacyFrameAutosaveName)"
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
