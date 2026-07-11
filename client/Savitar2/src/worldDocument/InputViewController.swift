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
    internal var stickyGotSaved = false

    internal var eventMonitor: Any?

    private var wordWrapEnabled = false
    private let statusBar = SessionStatusBarView()

    @IBOutlet var textView: NSTextView!

    public var backColor: NSColor {
        get { textView.backgroundColor }
        set { textView.backgroundColor = newValue }
    }

    public var foreColor: NSColor {
        get { textView.textColor ?? NSColor.white }
        set {
            textView.textColor = newValue
            textView.insertionPointColor = newValue
            setDefaultTextStyle()
        }
    }

    public var font: NSFont {
        get { textView.font ?? NSFont.systemFont(ofSize: 9) }
        set {
            textView.font = newValue
            setDefaultTextStyle()
        }
    }

    func setWordWrap(_ enabled: Bool) {
        wordWrapEnabled = enabled
        applyWordWrapIfNeeded()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        applyWordWrapIfNeeded()
    }

    private func applyWordWrapIfNeeded() {
        guard isViewLoaded else { return }
        WordWrapFormatting.apply(to: textView, enabled: wordWrapEnabled)
    }

    func rowHeight() -> CGFloat {
        textView.layoutManager?.defaultLineHeight(for: font) ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStatusBar()

        // Not setting the checkmark in the interface builder doesn't seem to work since OS X 10.9 Mavericks.
        // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        setDefaultTextStyle()

        newCmd()
    }

    func applyStatusBarStyle(world: World) {
        statusBar.apply(world: world)
    }

    func setStatusText(_ text: String) {
        statusBar.setText(text)
    }

    func clearStatusText() {
        statusBar.clear()
    }

    private func setupStatusBar() {
        guard let scrollView = textView.enclosingScrollView else { return }
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        view.addSubview(statusBar)

        let dividerOverlap = enclosingSplitView()?.dividerThickness ?? 0

        let topConstraints = view.constraints.filter { constraint in
            let firstIsScrollTop = constraint.firstItem as? NSView === scrollView && constraint.firstAttribute == .top
            let secondIsScrollTop = constraint.secondItem as? NSView === scrollView
                && constraint.secondAttribute == .top
            return firstIsScrollTop || secondIsScrollTop
        }
        NSLayoutConstraint.deactivate(topConstraints)

        NSLayoutConstraint.activate([
            statusBar.topAnchor.constraint(equalTo: view.topAnchor, constant: -dividerOverlap),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: statusBar.bottomAnchor)
        ])
    }

    private func enclosingSplitView() -> NSSplitView? {
        var ancestor: NSView? = view
        while let current = ancestor {
            if let splitView = current as? NSSplitView {
                return splitView
            }
            ancestor = current.superview
        }
        return nil
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

    func getTextLength() -> Int { textView.string.count }

    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = view.window,
              NSApplication.shared.keyWindow === locWindow else { return false }

        guard let sess = session else { return false }
        if handleEditingKey(with: event, session: sess) {
            return true
        }

        if sess.expandKeypress(with: event) { return true }

        if event.modifierFlags.contains(.control), event.keyCode == Keycode.s {
            toggleScrollLock()
            return true
        }

        // swiftlint:disable:next force_cast
        guard let doc = locWindow.windowController?.document as! Document? else { return false }

        switch event.keyCode {
        case Keycode.returnKey:
            doc.suppressChangeCount = true
            if event.modifierFlags.contains(.option) {
                // the carriage return is part of the input
                return false
            }

            var wasSaved = false
            let stickyCmd = sess.world.flags.contains(.stickyCmds)

            if getTextLength() > 0 {
                // save away the original command
                cmdIndex = cmdBuf.count
                wasSaved = saveCmd()

                if let processedCmd = textToCmd() {
                    // input trigger processing
                    var line = processedCmd.cmdStr
                    let effects = sess.determineEffects(line: &line, excludedType: .output)
                    if effects.count > 0 {
                        // We've got an input trigger effect, don't send a command, but process its effect(s).
                        // (Input triggers are intrinsically gagged.)
                        sess.handleEffects(effects)
                    } else {
                        // send the processed command to the server
                        sess.submitServerCmd(cmd: processedCmd)
                    }
                }
            } else {
                sess.sendString(string: sess.world.commandLinePostfix)
            }

            if !stickyCmd {
                prepareForNewCommand(wasSaved)
            } else {
                stickyGotSaved = true
                textView.selectAll(nil)
            }

        case Keycode.upArrow:
            doc.suppressChangeCount = true
            if cmdIndex > 1 {
                if getTextLength() > 0 {
                    _ = saveCmd()
                }
                cmdIndex -= 1
                recallCmd(index: cmdIndex)
            }

        case Keycode.downArrow:
            doc.suppressChangeCount = true
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

    private func handleEditingKey(with event: NSEvent, session: Session) -> Bool {
        switch InputEditingKeys.action(for: event) {
        case .moveLeft:
            textView.moveLeft(nil)
            return true
        case .moveRight:
            textView.moveRight(nil)
            return true
        case .beginningOfLine:
            textView.moveToBeginningOfLine(nil)
            return true
        case .sendInterrupt:
            session.sendString(string: InputEditingKeys.interruptCharacter)
            return true
        case .sendBell:
            session.sendString(string: InputEditingKeys.bellCharacter)
            return true
        case .none:
            return false
        }
    }

    private func toggleScrollLock() {
        guard let windowController = view.window?.windowController as? WindowController else { return }
        windowController.toggleScrollLockAction(self)
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

    func commandHistory() -> [String] {
        return cmdBuf.map { $0.cmdStr }.filter { !$0.isEmpty }
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
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: foreColor
        ]
    }

    func textToCmd() -> Command? {
        // TODO: HTML parsing

        return Command(text: textView.string)
    }

    // **************************************

    // MARK: - NSTextViewDelegate

    // **************************************

    func textView(_: NSTextView, shouldChangeTextIn affectedCharRange: NSRange,
                  replacementString: String?) -> Bool {
        guard session?.world.flags.contains(.stickyCmds) == true,
              affectedCharRange.location == 0,
              affectedCharRange.length > 0,
              let replacementString = replacementString,
              !replacementString.isEmpty else { return true }

        prepareForNewCommand(stickyGotSaved)
        textView.insertText(replacementString, replacementRange: NSRange(location: 0, length: 0))
        return false
    }

    func textView(_: NSTextView, menu _: NSMenu, for _: NSEvent, at _: Int) -> NSMenu? {
        // No contextual menu for our input view please
        return nil
    }

    func textDidChange(_: Notification) {
        guard !wordWrapEnabled else { return }
        WordWrapFormatting.synchronizeHorizontalSize(of: textView)
    }
}
