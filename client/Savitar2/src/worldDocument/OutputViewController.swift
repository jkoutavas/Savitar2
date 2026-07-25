//
//  OutputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/12/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class OutputViewController: OutputViewNavigationDelegate {
    private var makeAppend = false
    private var lastAppendID = 0
    weak var session: Session?

    private let statusBar = SessionStatusBarView()
    private let findBar = NSView()
    private let findSearchField = NSSearchField()
    private var findBarHeightConstraint: NSLayoutConstraint!
    private var outputTopToFindConstraint: NSLayoutConstraint!
    private var outputTopToStatusConstraint: NSLayoutConstraint!
    private var findEscapeMonitor: Any?

    lazy var outputView: OutputView = {
        class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
            func userContentController(_: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                print("📗webkit: \(message.body)")
            }
        }

        class ContextMenuMessageHandler: NSObject, WKScriptMessageHandler {
            weak var outputView: OutputView?

            func userContentController(_: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                guard let outputView,
                      let body = message.body as? [String: Any],
                      let x = cgFloat(body["x"]),
                      let y = cgFloat(body["y"]) else { return }

                outputView.showContextMenu(clientX: x, clientY: y)
            }

            private func cgFloat(_ value: Any?) -> CGFloat? {
                if let value = value as? CGFloat { return value }
                if let value = value as? Double { return CGFloat(value) }
                if let value = value as? NSNumber { return CGFloat(truncating: value) }
                return nil
            }
        }

        let userContentController = WKUserContentController()
        userContentController.add(LoggingMessageHandler(), name: "logging")
        let contextMenuMessageHandler = ContextMenuMessageHandler()
        userContentController.add(contextMenuMessageHandler, name: "contextMenu")
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController

        let outputView = OutputView(frame: .zero, configuration: webViewConfig)
        outputView.translatesAutoresizingMaskIntoConstraints = false
        outputView.navigationDelegate = self
        contextMenuMessageHandler.outputView = outputView

        return outputView
    }()

    override func viewDidLoad() {
        view.wantsLayer = true
        super.viewDidLoad()

        setupFindBar()
        view.addSubview(statusBar)
        view.addSubview(outputView)
        outputTopToStatusConstraint = outputView.topAnchor.constraint(equalTo: statusBar.bottomAnchor)
        outputTopToFindConstraint = outputView.topAnchor.constraint(equalTo: findBar.bottomAnchor)
        NSLayoutConstraint.activate([
            statusBar.topAnchor.constraint(equalTo: view.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            findBar.topAnchor.constraint(equalTo: statusBar.bottomAnchor),
            findBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            findBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outputTopToStatusConstraint,
            outputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            outputView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            outputView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    deinit {
        if let monitor = findEscapeMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func output(string: String, skipCapture: Bool = false) {
        let appending = makeAppend
        makeAppend = !string.endsWithNewline()
        outputView.output(string: string, makeAppend: makeAppend, appending: appending,
                          appendID: lastAppendID, skipCapture: skipCapture)
        if !makeAppend {
            lastAppendID += 1
        }
    }

    func outputEchoBack(_ text: String, skipCapture: Bool = false) {
        let appending = makeAppend
        makeAppend = !text.endsWithNewline()
        outputView.outputEchoBack(string: text, makeAppend: makeAppend, appending: appending,
                                  appendID: lastAppendID, skipCapture: skipCapture)
        if !makeAppend {
            lastAppendID += 1
        }
    }

    func outputLink(url: String, label: String, colorHex: String?) {
        let href = XchCmdLinkProcessor.escapeAttribute(url)
        let text = XchCmdLinkProcessor.escapeText(label)
        let style = colorHex.map { " style=\"color: #\($0)\"" } ?? ""
        let html = "<a href=\"\(href)\"\(style)>\(text)</a>"
        let appending = makeAppend
        makeAppend = false
        outputView.outputHTMLFragment(html, makeAppend: makeAppend, appending: appending, appendID: lastAppendID)
        lastAppendID += 1
    }

    func outputHTML(_ html: String, skipCapture: Bool = false) {
        let appending = makeAppend
        makeAppend = false
        let processed = XchCmdLinkProcessor.process(html)
        outputView.outputHTMLFragment(processed, makeAppend: false, appending: appending,
                                      appendID: lastAppendID, skipCapture: skipCapture)
        lastAppendID += 1
    }

    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           let filePath = SavitarFileLinkProcessor.filePath(from: url) {
            SavitarFileLinkProcessor.openFile(at: filePath)
            decisionHandler(.cancel)
            return
        }
        if let url = navigationAction.request.url,
           let command = XchCmdLinkProcessor.command(from: url) {
            session?.submitServerCmd(cmd: Command(text: command))
            decisionHandler(.cancel)
            return
        }
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }

    var isScrollLocked: Bool {
        return outputView.isScrollLocked
    }

    func setScrollLocked(_ locked: Bool) {
        outputView.setScrollLocked(locked)
    }

    @discardableResult
    func toggleScrollLock() -> Bool {
        return outputView.toggleScrollLock()
    }

    func setWordWrap(_ enabled: Bool) {
        outputView.setWordWrap(enabled)
    }

    func setStyle(world: World) {
        statusBar.apply(world: world)
        outputView.setStyle(world: world)
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

    func setLogging(world: World) {
        outputView.setLogging(world: world)
    }

    var isCapturing: Bool {
        return outputView.isCapturing
    }

    @discardableResult
    func startCapture(at path: String) -> Bool {
        return outputView.startCapture(at: path)
    }

    @discardableResult
    func stopCapture() -> String? {
        return outputView.stopCapture()
    }

    func printOutput(suggestedFilename: String = "Untitled") {
        guard let window = view.window else { return }
        let fontName = outputView.layoutFontName
        let fontSize = outputView.layoutFontSize
        outputView.extractPlainText { [weak self] text in
            DispatchQueue.main.async {
                self?.printPlainText(text, fontName: fontName, fontSize: fontSize,
                                     suggestedFilename: suggestedFilename, in: window)
            }
        }
    }

    private func printPlainText(_ text: String, fontName: String, fontSize: CGFloat,
                                suggestedFilename: String, in window: NSWindow) {
        let font = NSFont(name: fontName, size: fontSize)
            ?? NSFont.userFixedPitchFont(ofSize: fontSize)
            ?? NSFont(name: "Monaco", size: fontSize)
            ?? NSFont.systemFont(ofSize: fontSize)

        let textStorage = NSTextStorage(string: text, attributes: [
            .font: font,
            .foregroundColor: NSColor.black
        ])
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        // No wrapping — preserve the exact line lengths from the session (ASCII art shape).
        let textContainer = NSTextContainer(size: NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        ))
        textContainer.lineBreakMode = .byClipping
        textContainer.lineFragmentPadding = 0
        textContainer.widthTracksTextView = false
        layoutManager.addTextContainer(textContainer)
        layoutManager.ensureLayout(for: textContainer)

        let used = layoutManager.usedRect(for: textContainer)
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: used.width + 1, height: used.height + 1),
                                  textContainer: textContainer)
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.drawsBackground = true

        let printInfo = (NSPrintInfo.shared.copy() as? NSPrintInfo) ?? NSPrintInfo()
        printInfo.horizontalPagination = .automatic
        printInfo.verticalPagination = .automatic

        let operation = NSPrintOperation(view: textView, printInfo: printInfo)
        operation.jobTitle = suggestedFilename
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true
        operation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
    }

    func printSource() {
        outputView.printSource()
    }

    func performFindPanelAction(_ sender: Any?) {
        guard let menuItem = sender as? NSMenuItem else { return }
        switch NSFindPanelAction(rawValue: UInt(menuItem.tag)) {
        case .some(.showFindPanel):
            showFindBar(focus: true)
        case .some(.next):
            continueFind(forward: true)
        case .some(.previous):
            continueFind(forward: false)
        case .some(.setFindString):
            useSelectionForFind()
        default:
            break
        }
    }

    private func setupFindBar() {
        findBar.translatesAutoresizingMaskIntoConstraints = false
        findBar.clipsToBounds = true
        findBar.isHidden = true
        view.addSubview(findBar)

        findSearchField.translatesAutoresizingMaskIntoConstraints = false
        findSearchField.placeholderString = "Find in output"
        findSearchField.target = self
        findSearchField.action = #selector(findSearchFieldAction(_:))
        findSearchField.sendsWholeSearchString = true
        findBar.addSubview(findSearchField)

        findBarHeightConstraint = findBar.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            findBarHeightConstraint,
            findSearchField.leadingAnchor.constraint(equalTo: findBar.leadingAnchor, constant: 8),
            findSearchField.trailingAnchor.constraint(equalTo: findBar.trailingAnchor, constant: -8),
            findSearchField.centerYAnchor.constraint(equalTo: findBar.centerYAnchor)
        ])
    }

    private func showFindBar(focus: Bool) {
        findBar.isHidden = false
        findBarHeightConstraint.constant = 28
        outputTopToStatusConstraint.isActive = false
        outputTopToFindConstraint.isActive = true
        if let findString = NSPasteboard(name: .find).string(forType: .string), !findString.isEmpty {
            findSearchField.stringValue = findString
        }
        if focus {
            view.window?.makeFirstResponder(findSearchField)
        }
        installFindEscapeMonitor()
    }

    private func hideFindBar() {
        findBar.isHidden = true
        findBarHeightConstraint.constant = 0
        outputTopToFindConstraint.isActive = false
        outputTopToStatusConstraint.isActive = true
        removeFindEscapeMonitor()
        if let windowController = view.window?.windowController as? WindowController {
            windowController.focusInputLineIfAppropriate()
        } else {
            view.window?.makeFirstResponder(outputView)
        }
    }

    /// True when the Find field (or its field editor) is first responder.
    func isFindFieldActive(in window: NSWindow) -> Bool {
        guard !findBar.isHidden else { return false }
        if window.firstResponder === findSearchField {
            return true
        }
        if let editor = findSearchField.currentEditor() {
            return window.firstResponder === editor
        }
        return false
    }

    private func installFindEscapeMonitor() {
        guard findEscapeMonitor == nil else { return }
        findEscapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53, !self.findBar.isHidden {
                self.hideFindBar()
                return nil
            }
            return event
        }
    }

    private func removeFindEscapeMonitor() {
        if let monitor = findEscapeMonitor {
            NSEvent.removeMonitor(monitor)
            findEscapeMonitor = nil
        }
    }

    @objc private func findSearchFieldAction(_ sender: NSSearchField) {
        continueFind(forward: true, string: sender.stringValue)
    }

    private func continueFind(forward: Bool, string: String? = nil) {
        let query = string ?? findSearchField.stringValue
        guard !query.isEmpty else {
            showFindBar(focus: true)
            return
        }
        findSearchField.stringValue = query
        if findBar.isHidden {
            showFindBar(focus: false)
        }
        outputView.find(string: query, forward: forward)
    }

    private func useSelectionForFind() {
        outputView.selectedPlainText { [weak self] text in
            guard let self, let text, !text.isEmpty else { return }
            DispatchQueue.main.async {
                self.findSearchField.stringValue = text
                self.showFindBar(focus: true)
            }
        }
    }
}
