//
//  InputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/11/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

// Savitar 1.x origin:
// File:     CTinpPane.cp
// Purpose: Implements the session window's text input pane

import Cocoa

class InputViewController: NSViewController, NSTextViewDelegate {
    public weak var session: Session?

    internal let MAX_CMD_COUNT = 100
    internal var cmdBuf: [Command] = []
    internal var cmdIndex: Int = 0 // 0 == nothing in the command buffer. [1..MAX_CMD_COUNT] is 0-based array index +1

    internal var eventMonitor: Any?

    @IBOutlet var textView: NSTextView!

    public var backColor: NSColor {
        get {
            return textView.backgroundColor
        }
        set {
            textView.backgroundColor = newValue
        }
    }

    public var foreColor: NSColor {
        get {
            return textView.textColor ?? NSColor.white
        }
        set {
            textView.textColor = newValue
        }
    }

    public var font: NSFont {
        get {
            return textView.font ?? NSFont.systemFont(ofSize: 9)
        }
        set {
            textView.font = newValue
        }
    }

    func rowHeight() -> CGFloat {
        return textView.layoutManager?.defaultLineHeight(for: font) ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Not setting the checkmark in the interface builder doesn't seem to work since OS X 10.9 Mavericks.
        // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        newCmd()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        textView.isAutomaticSpellingCorrectionEnabled = false

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.myKeyDown(with: $0) ? nil : $0
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    // MARK: - Command Handling

    func clear() {
        textView.string = ""
    }

    func getTextLength() -> Int {
        return textView.string.count
    }

    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = view.window,
              NSApplication.shared.keyWindow === locWindow else { return false }

        guard let sess = session else { return false }
        if sess.expandKeypress(with: event) { return true }

        // swiftlint:disable force_cast
        guard let doc = locWindow.windowController?.document as! Document? else { return false }
        doc.suppressChangeCount = true

        switch event.keyCode {
        case Keycode.returnKey:
            if event.modifierFlags.contains(.option) {
                // the carriage return is part of the input
                return false
            }

            var wasSaved = false
            let stickyCmd = false // TODO: mConnection->GetWorld()->UseStickyCommands()

            if getTextLength() > 0 {
                // TODO: input trigger processing

                // save away the original command
                cmdIndex = cmdBuf.count
                wasSaved = saveCmd()

                // send the processed command to the server
                if let processedCmd = textToCmd() {
                    sess.submitServerCmd(cmd: processedCmd)
                }
            } else {
                // just send the carriage return
                sess.sendString(string: "\r")
            }

            if !stickyCmd {
                prepareForNewCommand(wasSaved)
            }

        case Keycode.upArrow:
            if cmdIndex > 1 {
                if getTextLength() > 0 {
                    _ = saveCmd()
                }
                cmdIndex -= 1
                recallCmd(index: cmdIndex)
            }

        case Keycode.downArrow:
            if cmdIndex < cmdBuf.count {
                if getTextLength() > 0 {
                    _ = saveCmd()
                }
                cmdIndex += 1
                recallCmd(index: cmdIndex)
            } else {
                // special "always a empty command at the bottom of the stack" handler
                if getTextLength() > 0 {
                    _ = saveCmd()
                    clear()
                    newCmd()
                }
            }

        default:
            return false
        }

        return true
    }

    func newCmd() {
        if cmdBuf.count == MAX_CMD_COUNT {
            // we're full -- nuke the oldest one
            cmdBuf.removeFirst()
        }
        cmdBuf.append(Command())
        cmdIndex = cmdBuf.count
    }

    func prepareForNewCommand(_ wasSaved: Bool) {
        clear()
        undoManager?.removeAllActions(withTarget: view)
        setDefaultTextStyle()
        if wasSaved {
            newCmd()
        }
    }

    func recallCmd(index: Int) {
        clear()

        // TODO: determine what word or words in the output are triggers

        let cmd = cmdBuf[index - 1]
        textView.string = cmd.cmdStr
    }

    func saveCmd() -> Bool {
        let newCmd: Command! = textToCmd()

        // Determine if it is really worth saving
        var index = cmdIndex < cmdBuf.count ? cmdIndex : cmdIndex - 1
        if index == 0 {
            index = 1
        }
        let lastCmd = cmdBuf[index - 1]
        if newCmd != lastCmd {
            // save away the command
            cmdBuf[cmdIndex - 1] = newCmd
            return true
        }
        return false
    }

    func setDefaultTextStyle() {
        // TODO:
    }

    func textToCmd() -> Command? {
        // TODO: HTML parsing

        return Command(text: textView.string)
    }

    // **************************************

    // MARK: - NSTextViewDelegate

    // **************************************

    func textView(_: NSTextView, menu _: NSMenu, for _: NSEvent, at _: Int) -> NSMenu? {
        // No contextual menu for our input view please
        return nil
    }
}
