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

    private let findBar = NSView()
    private let findSearchField = NSSearchField()
    private var findBarHeightConstraint: NSLayoutConstraint!
    private var findEscapeMonitor: Any?

    lazy var outputView: OutputView = {
        class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
            func userContentController(_: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                print("📗webkit: \(message.body)")
            }
        }

        let userContentController = WKUserContentController()
        userContentController.add(LoggingMessageHandler(), name: "logging")
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController

        let outputView = OutputView(frame: .zero, configuration: webViewConfig)
        outputView.translatesAutoresizingMaskIntoConstraints = false
        outputView.navigationDelegate = self

        return outputView
    }()

    override func viewDidLoad() {
        view.wantsLayer = true
        super.viewDidLoad()

        setupFindBar()
        view.addSubview(outputView)
        NSLayoutConstraint.activate([
            findBar.topAnchor.constraint(equalTo: view.topAnchor),
            findBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            findBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outputView.topAnchor.constraint(equalTo: findBar.bottomAnchor),
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

    func output(string: String) {
        let appending = makeAppend
        makeAppend = !string.endsWithNewline()
        outputView.output(string: string, makeAppend: makeAppend, appending: appending, appendID: lastAppendID)
        if !makeAppend {
            lastAppendID += 1
        }
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

    func setStyle(world: World) {
        outputView.setStyle(world: world)
    }

    func setLogging(world: World) {
        outputView.setLogging(world: world)
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
        removeFindEscapeMonitor()
        view.window?.makeFirstResponder(outputView)
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
