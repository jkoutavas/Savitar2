//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    private static let scrollLockButtonTag = 1001
    private static let eventsButtonTag = 1002
    private static let settingsButtonTag = 1003

    internal var reallyClosing = false
    private var eventsWindowController: NSWindowController?
    private weak var scrollLockButton: NSButton?
    private var windowTitle = ""

    override func windowDidLoad() {
        super.windowDidLoad()

        let titlebarController = storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("titlebarViewController"))
            as? NSTitlebarAccessoryViewController
        titlebarController?.layoutAttribute = .right
        // layoutAttribute has to be set before added to window
        if let titlebarController = titlebarController {
            configureTitlebarButtons(in: titlebarController.view)
            window?.addTitlebarAccessoryViewController(titlebarController)
        }
    }

    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        let components = displayName.components(separatedBy: ".")

        // display just the world's file name, with no extension. And, if the
        // world is read-only (v1.0) then append an indication of that.
        var status = ""
        guard let doc = document as? Document else { return "" }
        guard let world = doc.world else { return "" }
        world.editable = doc.version != 1
        if !world.editable {
            status = " [READ ONLY]"
        }

        windowTitle = components[0] + status
        return windowTitle
    }

    @IBAction func clearOutputAction(_: Any) {
        let splitViewController = contentViewController as? SessionViewController
        guard let svc = splitViewController else { return }
        guard let outputVC = svc.outputViewController else { return }
        outputVC.outputView.clear()
    }

    @IBAction func toggleScrollLockAction(_ sender: Any) {
        let splitViewController = contentViewController as? SessionViewController
        guard let svc = splitViewController else { return }
        let locked = svc.toggleScrollLock()
        updateScrollLockControl(locked: locked)
        if let menuItem = sender as? NSMenuItem {
            menuItem.state = locked ? .on : .off
        }
    }

    @IBAction func showWorldEvents(_: Any) {
        if eventsWindowController != nil {
            eventsWindowController?.window?.makeKeyAndOrderFront(self)
            return
        }

        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? NSWindowController else { return }
        guard let myWindow = controller.window else { return }
        myWindow.title = "\(windowTitle) - \(myWindow.title)"
        myWindow.delegate = self
        controller.windowFrameAutosaveName = "EventsWindowFrame - \(windowTitle)"
        eventsWindowController = controller

        if let splitViewController = myWindow.contentViewController as? EventsSplitViewController {
            guard let doc = document as? Document else { return }
            splitViewController.store = doc.store
            controller.showWindow(self)
        }
    }

    @IBAction func showWorldSetting(_: Any) {
        let bundle = Bundle(for: Self.self)
        let settingsStoryboard = NSStoryboard(name: "WorldSettings", bundle: bundle)

        // we contain the WorldSettingsController into a NSWindowController so we can set a minimum resize on the sheet
        guard let wc = settingsStoryboard.instantiateInitialController() as? NSWindowController else { return }
        guard let vc = wc.window?.contentViewController as? WorldSettingsController else { return }
        guard let doc = document as? Document else { return }
        vc.world = doc.world
        vc.completionHandler = { apply, editedWorld in
            if apply == true {
                self.worldDidChange(from: editedWorld!)
            }
            self.window?.endSheet(vc.view.window!, returnCode: NSApplication.ModalResponse.OK)
        }
        window?.beginSheet(wc.window!)
    }

    private func worldDidChange(from fromWorld: World) {
        guard let doc = document as? Document else { return }
        doc.undoManager?.registerUndo(withTarget: self, handler: { [oldWorld = doc.world] _ in
            self.worldDidChange(from: oldWorld!)
        })

        doc.undoManager?.setActionName(NSLocalizedString("Change World Settings",
                                                         comment: "Change World Settings"))
        doc.worldDidChange(fromWorld: fromWorld)
        updateViews(fromWorld)
    }

    func updateViews(_ newValue: World?) {
        guard let window = self.window else { return }

        let autosaveName = window.representedFilename
        window.setFrameUsingName(autosaveName)
        window.setFrameAutosaveName(autosaveName)

        let splitViewController = contentViewController as? SessionViewController

        guard let svc = splitViewController else { return }
        guard let inputVC = svc.inputViewController else { return }
        guard let outputVC = svc.outputViewController else { return }
        window.makeFirstResponder(inputVC.textView)

        guard let w = newValue else { return }

        inputVC.foreColor = w.foreColor
        inputVC.backColor = w.backColor
        outputVC.view.layer?.backgroundColor = w.backColor.cgColor
        outputVC.setStyle(world: w)

        if let font = NSFont(name: w.fontName, size: w.fontSize) {
            inputVC.font = font
        }

        outputVC.setLogging(world: w)

        guard let doc = document as? Document else { return }

        if doc.version == 1 {
            window.setContentSize(w.windowSize)
            if let screenSize = NSScreen.main?.frame.size {
                window.setFrameTopLeftPoint(NSPoint(x: w.position.x,
                                                    y: screenSize.height - w.position.y + window.titlebarHeight))
            }

            let dividerHeight: CGFloat = svc.splitView.dividerThickness
            let rowHeight = inputVC.rowHeight
            let split: CGFloat = w.windowSize.height - dividerHeight - rowHeight() * CGFloat(w.inputRows + 1)
            svc.splitView.setPosition(split, ofDividerAt: 0)

            window.setIsZoomed(w.zoomed)
        }

        splitViewController?.splitView.autosaveName = "splitViewAutoSave" // enables splitview position autosaving
        updateScrollLockControl(locked: svc.isScrollLocked)
    }

    private func configureTitlebarButtons(in titlebarView: NSView) {
        guard let button = titlebarView.viewWithTag(Self.scrollLockButtonTag) as? NSButton else { return }
        configureTitlebarButton(button,
                                action: #selector(toggleScrollLockAction(_:)),
                                image: Self.lockIcon(locked: false),
                                alternateImage: Self.lockIcon(locked: true),
                                label: "Scroll Lock")
        scrollLockButton = button
        updateScrollLockControl(locked: false)

        if let eventsButton = titlebarView.viewWithTag(Self.eventsButtonTag) as? NSButton {
            configureTitlebarButton(eventsButton,
                                    action: #selector(showWorldEvents(_:)),
                                    image: Self.eventsIcon(),
                                    alternateImage: nil,
                                    label: "World Events")
        }

        if let settingsButton = titlebarView.viewWithTag(Self.settingsButtonTag) as? NSButton {
            configureTitlebarButton(settingsButton,
                                    action: #selector(showWorldSetting(_:)),
                                    image: Self.settingsIcon(),
                                    alternateImage: nil,
                                    label: "World Settings")
        }
    }

    private func configureTitlebarButton(_ button: NSButton,
                                         action: Selector,
                                         image: NSImage,
                                         alternateImage: NSImage?,
                                         label: String) {
        button.target = self
        button.action = action
        button.title = ""
        button.image = image
        button.alternateImage = alternateImage
        button.imagePosition = .imageOnly
        button.toolTip = label
        button.setAccessibilityLabel(label)
        button.bezelStyle = .texturedRounded
        button.imageScaling = .scaleProportionallyDown
    }

    private func updateScrollLockControl(locked: Bool) {
        scrollLockButton?.state = locked ? .on : .off
        scrollLockButton?.toolTip = locked ? "Scroll lock is on" : "Scroll lock is off"
        scrollLockButton?.setAccessibilityValue(locked ? "On" : "Off")
    }

    private static func iconImage(_ drawing: @escaping (NSRect) -> Void) -> NSImage {
        let image = NSImage(size: NSSize(width: 16, height: 16), flipped: false) { rect in
            NSColor.black.setFill()
            NSColor.black.setStroke()
            drawing(rect)
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func lockIcon(locked: Bool) -> NSImage {
        return iconImage { _ in
            let body = NSBezierPath(roundedRect: NSRect(x: 3, y: 1.8, width: 10, height: 7.6),
                                    xRadius: 1.3,
                                    yRadius: 1.3)
            body.fill()

            let shackle = NSBezierPath()
            shackle.lineWidth = 2
            shackle.lineCapStyle = .round
            shackle.move(to: NSPoint(x: locked ? 5 : 6.5, y: 8.4))
            shackle.line(to: NSPoint(x: locked ? 5 : 6.5, y: 10.9))
            shackle.curve(to: NSPoint(x: locked ? 11 : 13.2, y: 10.9),
                          controlPoint1: NSPoint(x: locked ? 5 : 6.5, y: 14),
                          controlPoint2: NSPoint(x: locked ? 11 : 13.2, y: 14))
            shackle.line(to: NSPoint(x: locked ? 11 : 13.2, y: locked ? 8.4 : 10.4))
            shackle.stroke()
        }
    }

    private static func eventsIcon() -> NSImage {
        return iconImage { _ in
            let bolt = NSBezierPath()
            bolt.move(to: NSPoint(x: 9.2, y: 15))
            bolt.line(to: NSPoint(x: 3.8, y: 7.3))
            bolt.line(to: NSPoint(x: 8.1, y: 7.3))
            bolt.line(to: NSPoint(x: 6.5, y: 1))
            bolt.line(to: NSPoint(x: 12.4, y: 9.1))
            bolt.line(to: NSPoint(x: 8, y: 9.1))
            bolt.close()
            bolt.fill()
        }
    }

    private static func settingsIcon() -> NSImage {
        return iconImage { _ in
            let center = NSPoint(x: 8, y: 8)
            let teeth = 8
            let path = NSBezierPath()
            for index in 0..<(teeth * 2) {
                let angle = CGFloat(index) * .pi / CGFloat(teeth) - .pi / 2
                let radius: CGFloat = index.isMultiple(of: 2) ? 7 : 5.3
                let point = NSPoint(x: center.x + cos(angle) * radius,
                                    y: center.y + sin(angle) * radius)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.line(to: point)
                }
            }
            path.close()
            path.appendOval(in: NSRect(x: 5.4, y: 5.4, width: 5.2, height: 5.2))
            path.windingRule = .evenOdd
            path.fill()
        }
    }

    func reallyClose() {
        reallyClosing = true
        if let window = self.window {
            window.close()
        }
    }

    // ***************************

    // MARK: - NSWindowDelegate

    // ***************************

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        guard let doc = document as? Document else { return nil }
        return doc.undoManager
    }

    internal func windowShouldClose(_ window: NSWindow) -> Bool {
        if AppContext.shared.isTerminating || reallyClosing {
            if window == self.window {
                (document as? Document)?.session?.close()
            }
            return true
        }

        if window == self.window {
            guard let doc = document as? Document else { return true }
            guard let session = doc.session else { return true }
            if session.status == .ConnectComplete {
                session.close()
                return false
            }
            return true
        } else if window == eventsWindowController?.window {
            eventsWindowController = nil
            return true
        }

        return false // this shouldn't ever be reached
    }
}

extension WindowController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(toggleScrollLockAction(_:)) {
            let splitViewController = contentViewController as? SessionViewController
            menuItem.state = splitViewController?.isScrollLocked == true ? .on : .off
        }
        return true
    }
}
