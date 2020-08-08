//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        let titlebarController = self.storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("titlebarViewController"))
            as? NSTitlebarAccessoryViewController
        titlebarController?.layoutAttribute = .right
        // layoutAttribute has to be set before added to window
        self.window?.addTitlebarAccessoryViewController(titlebarController!)
    }

    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        let components = displayName.components(separatedBy: ".")

        // display just the world's file name, with no extension. And, if the
        // world is read-only (v1.0) then append an indication of that.
        var status = ""
        guard let doc = document as? Document else { return "" }
        doc.world.editable = doc.version != 1
        if !doc.world.editable {
            status = " [READ ONLY]"
        }
        return components[0] + status
    }

    @IBAction func showWorldEvents(_ sender: Any) {
        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? NSWindowController else {
            return
        }
        guard let myWindow = controller.window else {
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        let vc = NSWindowController(window: myWindow)

        if let eventsController = myWindow.contentViewController as? EventsViewController {
            guard let doc = document as? Document else { return }
            controller.document = doc
            eventsController.store = doc.store

            vc.showWindow(self)
        }
        myWindow.makeKeyAndOrderFront(self)
    }

    @IBAction func showWorldSetting(_ sender: Any) {
        // we contain the WorldSettingsController into a NSWindowController so we can set a minimum resize on the sheet
        guard let wc = storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("World Settings Window Controller"))
            as? NSWindowController else { return }
        guard let vc = wc.window?.contentViewController as? WorldSettingsController else { return }
        guard let doc = document as? Document else { return }
        vc.world = doc.world
        vc.completionHandler = { apply, editedWorld in
            if apply == true {
                self.worldDidChange(from: editedWorld!)
            }
            self.window?.endSheet(vc.view.window!, returnCode: NSApplication.ModalResponse.OK)
        }
        self.window?.beginSheet(wc.window!)
    }

    private func worldDidChange(from fromWorld: World) {
        guard let doc = document as? Document else { return }
        doc.undoManager?.registerUndo(withTarget: self, handler: { [oldWorld = doc.world] (_) in
            self.worldDidChange(from: oldWorld)
        })

        doc.undoManager?.setActionName(NSLocalizedString("Change World Settings",
                                                         comment: "Change World Settings"))

        doc.world = fromWorld
        self.updateViews(fromWorld)
    }

    func updateViews(_ newValue: World?) {

        let splitViewController = contentViewController as? SplitViewController

        guard let svc = splitViewController else { return }
        guard let inputVC = svc.inputViewController else { return }
        guard let outputVC = svc.outputViewController else { return }
        window?.makeFirstResponder(inputVC.textView)

        guard let w = newValue else { return }

        inputVC.foreColor = w.foreColor
        inputVC.backColor = w.backColor
        outputVC.view.layer?.backgroundColor = w.backColor.cgColor
        outputVC.setStyle(world: w)

        if let font = NSFont(name: w.fontName, size: w.fontSize) {
            inputVC.font = font
        }

        guard let doc = document as? Document else { return }
        if doc.version == 1 {
            window?.setContentSize(w.windowSize)
            if let titleHeight = window?.titlebarHeight {
                if let screenSize = NSScreen.main?.frame.size {
                    window?.setFrameTopLeftPoint(NSPoint(x: w.position.x,
                                                         y: screenSize.height - w.position.y + titleHeight))
                }
            }

            let dividerHeight: CGFloat = svc.splitView.dividerThickness
            let rowHeight = inputVC.rowHeight
            let split: CGFloat = w.windowSize.height - dividerHeight - rowHeight() * CGFloat(w.inputRows+1)
            svc.splitView.setPosition(split, ofDividerAt: 0)

            window?.setIsZoomed(w.zoomed)
        }

        splitViewController?.splitView.autosaveName = "splitViewAutoSave" // enables splitview position autosaving
    }
}
