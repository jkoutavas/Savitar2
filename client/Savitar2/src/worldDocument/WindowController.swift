//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    internal var reallyClosing = false
    private var eventsWindowController: NSWindowController?
    private var windowTitle = ""

    override func windowDidLoad() {
        super.windowDidLoad()

        let titlebarController = storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("titlebarViewController"))
            as? NSTitlebarAccessoryViewController
        titlebarController?.layoutAttribute = .right
        // layoutAttribute has to be set before added to window
        window?.addTitlebarAccessoryViewController(titlebarController!)
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
