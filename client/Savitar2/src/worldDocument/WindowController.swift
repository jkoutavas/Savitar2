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
    private var savedTitleWhileSettingsSheetOpen: String?
    private let resolutionOverlay = ResolutionOverlay()
    private weak var observedSplitView: NSSplitView?
    private var isApplyingPaneLayout = false
    private var needsPaneLayout = false
    private var isUserResizingSplit = false

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

        if let window {
            SavitarHelpButton.installInTitleBar(of: window, for: .worldSession)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(colorsDidChange),
                                               name: .savitarColorsChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Re-apply the output stylesheet when the global ANSI palette changes.
    @objc private func colorsDidChange() {
        guard let doc = document as? Document, let world = doc.world else { return }
        let splitViewController = contentViewController as? SessionViewController
        splitViewController?.outputViewController?.setWordWrap(doc.session?.wordWrapEnabled ?? false)
        splitViewController?.outputViewController?.setStyle(world: world)
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
        guard let settingsWC = settingsStoryboard.instantiateInitialController()
            as? WorldSettingsWindowController else { return }
        guard let vc = settingsWC.window?.contentViewController as? WorldSettingsController else { return }
        guard let doc = document as? Document else { return }
        vc.world = doc.world
        settingsWC.settingsController = vc
        vc.sheetWindowController = settingsWC
        savedTitleWhileSettingsSheetOpen = window?.title
        vc.onSheetTitleChange = { [weak self] title in
            self?.window?.title = title
        }
        vc.completionHandler = { [weak self] apply, editedWorld in
            guard let self else { return }
            if apply == true {
                self.worldDidChange(from: editedWorld!)
            }
            if let saved = self.savedTitleWhileSettingsSheetOpen {
                self.window?.title = saved
            }
            self.savedTitleWhileSettingsSheetOpen = nil
            self.window?.endSheet(vc.view.window!, returnCode: NSApplication.ModalResponse.OK)
        }
        window?.beginSheet(settingsWC.window!)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        applyPendingPaneLayoutIfNeeded()
    }

    private func worldDidChange(from fromWorld: World) {
        guard let doc = document as? Document else { return }
        doc.undoManager?.registerUndo(withTarget: self, handler: { [oldWorld = doc.world] _ in
            self.worldDidChange(from: oldWorld!)
        })

        doc.undoManager?.setActionName(NSLocalizedString("Change World Settings",
                                                         comment: "Change World Settings"))
        doc.worldDidChange(fromWorld: fromWorld)
        let wordWrap = doc.session?.wordWrapEnabled ?? false
        updateViews(fromWorld, wordWrap: wordWrap, applyPaneLayout: true)
    }

    func updateViews(_ newValue: World?, wordWrap: Bool = false, applyPaneLayout: Bool = false) {
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
        inputVC.setWordWrap(wordWrap)
        outputVC.view.layer?.backgroundColor = w.backColor.cgColor
        outputVC.setWordWrap(wordWrap)
        outputVC.setStyle(world: w)

        if let font = NSFont(name: w.fontName, size: w.fontSize) {
            inputVC.font = font
        }

        outputVC.setLogging(world: w)

        guard let doc = document as? Document else { return }

        if applyPaneLayout {
            needsPaneLayout = true
            applyPendingPaneLayoutIfNeeded()
        }

        if doc.version == 1 {
            if let screenSize = NSScreen.main?.frame.size {
                window.setFrameTopLeftPoint(NSPoint(x: w.position.x,
                                                    y: screenSize.height - w.position.y + window.titlebarHeight))
            }
            window.setIsZoomed(w.zoomed)
        }

        installSplitViewObservationIfNeeded(svc.splitView)
        svc.splitView.autosaveName = "splitViewAutoSave"
        updateScrollLockControl(locked: svc.isScrollLocked)
    }

    private func installSplitViewObservationIfNeeded(_ splitView: NSSplitView) {
        guard observedSplitView !== splitView else { return }
        observedSplitView = splitView
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(splitViewDidResizeSubviews(_:)),
            name: NSSplitView.didResizeSubviewsNotification,
            object: splitView
        )
    }

    private func applyPendingPaneLayoutIfNeeded() {
        guard needsPaneLayout,
              let window, window.isVisible,
              let world = (document as? Document)?.world,
              let session = contentViewController as? SessionViewController,
              session.splitView.subviews.count >= 2 else { return }

        needsPaneLayout = false
        applyPaneDimensions(world: world,
                            session: session,
                            font: sessionFont(for: world),
                            fromResolution: true)
    }

    private func sessionFont(for world: World) -> NSFont {
        NSFont(name: world.fontName, size: world.fontSize)
            ?? NSFont.userFixedPitchFont(ofSize: world.fontSize)
            ?? NSFont.systemFont(ofSize: world.fontSize)
    }

    private func applyPaneDimensions(world: World,
                                     session: SessionViewController,
                                     font: NSFont,
                                     fromResolution: Bool) {
        guard let window, session.splitView.subviews.count >= 2 else { return }

        isApplyingPaneLayout = true
        defer { isApplyingPaneLayout = false }

        if fromResolution {
            world.windowSize = .zero
        }

        PaneDimensions.apply(world: world, to: window, splitView: session.splitView, font: font)

        if fromResolution {
            world.windowSize = window.contentRect(forFrameRect: window.frame).size
        }
    }

    private func showResolutionOverlay(outputRows: Int, columns: Int) {
        guard let window else { return }
        let text = PaneDimensions.resolutionLabel(columns: columns,
                                                  outputRows: outputRows,
                                                  inputRows: 0)
        let point = NSEvent.mouseLocation
        resolutionOverlay.show(text: text, near: point, in: window.screen)
    }

    @objc private func splitViewDidResizeSubviews(_ notification: Notification) {
        guard !isApplyingPaneLayout,
              notification.object as? NSSplitView === observedSplitView,
              let doc = document as? Document,
              let world = doc.world,
              let session = contentViewController as? SessionViewController,
              let window else { return }

        let font = sessionFont(for: world)
        session.splitView.layoutSubtreeIfNeeded()
        var measured = world
        PaneDimensions.measure(world: &measured, window: window, splitView: session.splitView, font: font)

        if NSEvent.pressedMouseButtons != 0 {
            isUserResizingSplit = true
            showResolutionOverlay(outputRows: measured.outputRows, columns: measured.columns)
        } else if isUserResizingSplit {
            isUserResizingSplit = false
            resolutionOverlay.hide()
            doc.world = measured
            doc.updateChangeCount(.changeDone)
        }
    }

    private func persistMeasuredPaneDimensions() {
        guard let doc = document as? Document,
              let world = doc.world,
              let session = contentViewController as? SessionViewController,
              let window else { return }

        session.splitView.layoutSubtreeIfNeeded()
        var measured = world
        PaneDimensions.measure(world: &measured,
                               window: window,
                               splitView: session.splitView,
                               font: sessionFont(for: world))
        doc.world = measured
        doc.updateChangeCount(.changeDone)
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

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        // Programmatic layout (restore, RESOLUTION apply) also calls through here; only show
        // the yellow box for a live user drag so it does not stick at the cursor on launch.
        guard !isApplyingPaneLayout,
              sender.inLiveResize,
              let world = (document as? Document)?.world,
              let session = contentViewController as? SessionViewController else {
            return frameSize
        }

        let font = sessionFont(for: world)
        let contentSize = sender.contentRect(forFrameRect: NSRect(origin: .zero, size: frameSize)).size
        let charW = max(PaneDimensions.charWidth(for: font), 1)
        let lineH = max(PaneDimensions.lineHeight(for: font), 1)
        let columns = max(1, Int(floor(contentSize.width / charW)))
        let outputRows = max(1, Int(floor(contentSize.height / lineH)) - world.inputRows - 1)
        showResolutionOverlay(outputRows: outputRows, columns: columns)
        return frameSize
    }

    func windowDidEndLiveResize(_: Notification) {
        resolutionOverlay.hide()
        persistMeasuredPaneDimensions()
    }

    func windowWillReturnUndoManager(_: NSWindow) -> UndoManager? {
        guard let doc = document as? Document else { return nil }
        return doc.undoManager
    }

    internal func windowShouldClose(_ window: NSWindow) -> Bool {
        if AppContext.shared.isTerminating || reallyClosing {
            if window == self.window {
                if let session = (document as? Document)?.session,
                   session.status == .ConnectComplete {
                    session.close(sendLogoff: true)
                }
            }
            return true
        }

        if window == self.window {
            guard let doc = document as? Document else { return true }
            guard let session = doc.session else { return true }
            if session.status == .ConnectComplete {
                session.close(sendLogoff: true)
                if doc.world?.flags.contains(.autoClose) == true {
                    reallyClose()
                }
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
