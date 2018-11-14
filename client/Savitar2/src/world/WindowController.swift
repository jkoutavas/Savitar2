//
//  WindowController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/4/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    var world: World? {
        get {
            return _world
        }
        set {
            updateWorld(newValue)
        }
    }

    private var _world: World?

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
        if let editable = world?.editable {
            if !editable {
                status = " [READ ONLY]"
            }
        }
        return components[0] + status
    }

    @IBAction func showWorldSetting(_ sender: Any) {
        // we contain the WorldSettingsController into a NSWindowController so we can set a minimum resize on the sheet
        guard let wc = storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("World Settings Window Controller"))
            as? NSWindowController else { return }
        guard let vc = wc.window?.contentViewController as? WorldSettingsController else { return }
        vc.world = world
        vc.windowController = self

        self.window?.beginSheet(wc.window!, completionHandler: { (returnCode) in
            // TODO: work-out save vs. cancel, etc.
            print("world settings sheet has been dismissed. returnCode=\(returnCode)")
        })
    }

    func updateWorld(_ newValue: World?) {
        _world = newValue

        let splitViewController = contentViewController as? SplitViewController

        guard let svc = splitViewController else { return }
        guard let inputVC = svc.inputViewController else { return }
        guard let outputVC = svc.outputViewController else { return }
        window?.makeFirstResponder(inputVC.textView)

        guard let w = _world else { return }

        inputVC.foreColor = w.foreColor
        inputVC.backColor = w.backColor
        outputVC.foreColor = w.foreColor
        outputVC.backColor = w.backColor

        if let font = NSFont(name: w.fontName, size: w.fontSize) {
            inputVC.font = font
            outputVC.font = font
        }

        if w.version == 1 {
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

        windowFrameAutosaveName = NSWindow.FrameAutosaveName(w.GUID)
        splitViewController?.splitView.autosaveName = NSSplitView.AutosaveName(w.GUID)
    }
}
