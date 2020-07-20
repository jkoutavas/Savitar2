//
//  InputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/11/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class InputViewController: ViewController {

    public weak var endpoint: Endpoint?

    internal var eventMonitor: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Not setting the checkmark in the interface builder doesn't seem to work since OS X 10.9 Mavericks.
        // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
        self.textView?.isAutomaticQuoteSubstitutionEnabled = false
        self.textView?.isAutomaticDashSubstitutionEnabled = false
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            return self.myKeyDown(with: $0) ? nil : $0
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
           NSApplication.shared.keyWindow === locWindow else { return false }

        guard let ep = self.endpoint else { return false }
        if ep.expandKeypress(with: event) { return true }

        // swiftlint:disable force_cast
        guard let doc = locWindow.windowController?.document as! Document? else { return false }
        doc.suppressChangeCount = true

        if event.keyCode == Keycode.returnKey {
            // we're wrapping this in an async call so we call unwind the
            // keyDown event off the stack before clearing the string
            DispatchQueue.main.async { [unowned self] in
                if let textView = self.textView, textView.string.count > 0 {
                    ep.sendString(string: textView.string)
                    self.undoManager?.removeAllActions(withTarget: self.view)
                    // TODO: add command history support
                    textView.string = ""
                }
            }
        }
        return false
    }
}
