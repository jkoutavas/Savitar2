//
//  WorldPickerWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// World Picker utility window chrome ([HIG.md](../../../docs/HIG.md) — World Picker; Story 7).
final class WorldPickerWindowController: NSWindowController, NSWindowDelegate {
    private static let frameOriginKey = "WorldPickerFrameOrigin"

    private var escapeKeyMonitor: Any?
    private var hasPlacedFrame = false

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window else { return }

        window.configureAsSettingsWindow(delegate: self)
        window.title = "World Picker"
        installEscapeKeyMonitor()
        if let picker = contentViewController as? WorldPickerController {
            picker.pickerWindowController = self
        }
    }

    deinit {
        if let escapeKeyMonitor {
            NSEvent.removeMonitor(escapeKeyMonitor)
        }
    }

    func present() {
        resizeToFitWorldList()
        placeWindowIfNeeded()
        showWindow(self)
    }

    func resizeToFitWorldList() {
        guard let window, let picker = contentViewController as? WorldPickerController else { return }
        window.fitContentSize(picker.fittingContentSize(), centerIfNeeded: false)
    }

    override func cancelOperation(_ sender: Any?) {
        window?.performClose(sender)
    }

    private func installEscapeKeyMonitor() {
        escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, window?.isKeyWindow == true else { return event }
            if event.keyCode == 53 {
                cancelOperation(self)
                return nil
            }
            if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers?.lowercased() == "w" {
                cancelOperation(self)
                return nil
            }
            return event
        }
    }

    private func placeWindowIfNeeded() {
        guard let window, !hasPlacedFrame else { return }
        hasPlacedFrame = true

        if let origin = savedFrameOrigin() {
            var frame = window.frame
            frame.origin = origin
            window.setFrame(frame, display: true)
        } else {
            window.center()
        }
    }

    private func savedFrameOrigin() -> NSPoint? {
        guard let value = UserDefaults.standard.string(forKey: Self.frameOriginKey) else { return nil }
        let parts = value.split(separator: ",")
        guard parts.count == 2,
              let x = Double(parts[0]),
              let y = Double(parts[1]) else { return nil }
        return NSPoint(x: x, y: y)
    }

    private func saveFrameOrigin() {
        guard let window else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set("\(origin.x),\(origin.y)", forKey: Self.frameOriginKey)
    }

    func windowWillClose(_: Notification) {
        saveFrameOrigin()
        AppContext.shared.worldPickerWindowDidClose()
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        AppContext.shared.appUndoManager
    }
}
