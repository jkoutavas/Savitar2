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

class InputViewController: ViewController {
    public weak var endpoint: Endpoint?

    internal let MAX_CMD_COUNT = 100
    internal var cmdBuf: [Command] = []
    internal var cmdIndex: Int = 0 // 0 == nothing in the command buffer. [1..MAX_CMD_COUNT] is 0-based array index +1

    internal var eventMonitor: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Not setting the checkmark in the interface builder doesn't seem to work since OS X 10.9 Mavericks.
        // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false

        newCmd()
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

    // MARK: - Command Handling

    func clear() {
        self.textView.string = ""
    }

    func getTextLength() -> Int {
        return self.textView.string.count
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

        switch event.keyCode {
        case Keycode.returnKey:
            if event.modifierFlags.contains(.option) {
                // the carriage return is part of the input
                return false
            }

            var wasSaved = false
            let stickyCmd = false // TODO mConnection->GetWorld()->UseStickyCommands()

            if getTextLength() > 0 {
                // TODO: input trigger processing

                // save away the original command
                self.cmdIndex = cmdBuf.count
                wasSaved = self.saveCmd()

                // send the processed command to the server
                if let processedCmd = textToCmd() {
                    ep.sendCommand(cmd: processedCmd)
                }
             } else {
                // just send the carriage return
                ep.sendString(string: "\r")
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
        self.undoManager?.removeAllActions(withTarget: self.view)
        setDefaultTextStyle()
        if wasSaved {
            newCmd()
        }
    }

    func recallCmd(index: Int) {
        clear()

        // TODO: determine what word or words in the output are triggers

        let cmd = cmdBuf[index-1]
        textView.string = cmd.cmdStr
    }

    func saveCmd() -> Bool {
        var newCmd: Command! = textToCmd()

        // Determine if it is really worth saving
        var index = cmdIndex < cmdBuf.count ? cmdIndex : cmdIndex - 1
        if index == 0 {
            index = 1
        }
        let lastCmd = cmdBuf[index-1]
        if newCmd != lastCmd {
            // save away the command
            cmdBuf[cmdIndex-1] = newCmd
            return true
        }
        return false
    }

    func setDefaultTextStyle() {
        // TODO
    }

    func textToCmd() -> Command? {
        // TODO HTML parsing

        return Command(text: textView.string)
    }
}
