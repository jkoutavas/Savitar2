//
//  HelpGuideWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

/// Presents the bundled user guide in a Savitar window (Story 16).
final class HelpGuideWindowController: NSWindowController, WKNavigationDelegate {
    static let shared = HelpGuideWindowController()

    private let contentView = NSView()
    private let findBar = NSView()
    private let findSearchField = NSSearchField()
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private var findBarHeightConstraint: NSLayoutConstraint!
    private var webViewTopToFindConstraint: NSLayoutConstraint!
    private var webViewTopToContentConstraint: NSLayoutConstraint!
    private var findEscapeMonitor: Any?
    private var pendingAnchor: String?

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 640),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Savitar Help"
        window.setContentSize(NSSize(width: 720, height: 640))
        window.center()
        super.init(window: window)

        setupFindBar()
        setupContentLayout()
        window.contentView = contentView

        webView.appearance = nil
        webView.navigationDelegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appearanceDidChange),
            name: .savitarAppearanceChanged,
            object: nil
        )
    }

    deinit {
        if let monitor = findEscapeMonitor {
            NSEvent.removeMonitor(monitor)
        }
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func isHelpWindow(_ window: NSWindow?) -> Bool {
        return window === self.window
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

    func show(anchor: String) {
        guard let (indexURL, readAccessURL) = Self.guideURLs() else {
            presentMissingGuideAlert()
            return
        }

        pendingAnchor = anchor == SavitarHelp.Anchor.home ? nil : anchor

        var url = indexURL
        if let pendingAnchor {
            var components = URLComponents(url: indexURL, resolvingAgainstBaseURL: false)
            components?.fragment = pendingAnchor
            if let anchored = components?.url {
                url = anchored
            }
        }

        webView.loadFileURL(url, allowingReadAccessTo: readAccessURL)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        scrollToPendingAnchor(in: webView)
    }

    // MARK: - Layout

    private func setupContentLayout() {
        webView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(findBar)
        contentView.addSubview(webView)

        webViewTopToContentConstraint = webView.topAnchor.constraint(equalTo: contentView.topAnchor)
        webViewTopToFindConstraint = webView.topAnchor.constraint(equalTo: findBar.bottomAnchor)

        NSLayoutConstraint.activate([
            findBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            findBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            findBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webViewTopToContentConstraint,
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupFindBar() {
        findBar.translatesAutoresizingMaskIntoConstraints = false
        findBar.clipsToBounds = true
        findBar.isHidden = true

        findSearchField.translatesAutoresizingMaskIntoConstraints = false
        findSearchField.placeholderString = "Find in help"
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

    // MARK: - Find

    private func showFindBar(focus: Bool) {
        findBar.isHidden = false
        findBarHeightConstraint.constant = 28
        webViewTopToContentConstraint.isActive = false
        webViewTopToFindConstraint.isActive = true
        if let findString = NSPasteboard(name: .find).string(forType: .string), !findString.isEmpty {
            findSearchField.stringValue = findString
        }
        if focus {
            window?.makeFirstResponder(findSearchField)
        }
        installFindEscapeMonitor()
    }

    private func hideFindBar() {
        findBar.isHidden = true
        findBarHeightConstraint.constant = 0
        webViewTopToFindConstraint.isActive = false
        webViewTopToContentConstraint.isActive = true
        removeFindEscapeMonitor()
        window?.makeFirstResponder(webView)
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
        find(string: query, forward: forward)
    }

    private func find(string: String, forward: Bool) {
        let pasteboard = NSPasteboard(name: .find)
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)

        let escaped = string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "\\n")
        let backwards = forward ? "false" : "true"
        webView.evaluateJavaScript(
            "window.find('\(escaped)', false, \(backwards), true, false, true, false);",
            completionHandler: nil
        )
    }

    private func useSelectionForFind() {
        webView.evaluateJavaScript("window.getSelection()?.toString() ?? ''") { [weak self] result, _ in
            guard let self else { return }
            let text = (result as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !text.isEmpty else { return }
            DispatchQueue.main.async {
                self.findSearchField.stringValue = text
                self.showFindBar(focus: true)
            }
        }
    }

    // MARK: - Navigation

    @objc private func appearanceDidChange() {
        guard window?.isVisible == true, webView.url != nil else { return }
        webView.reload()
    }

    private func scrollToPendingAnchor(in webView: WKWebView) {
        guard let anchor = pendingAnchor else { return }
        pendingAnchor = nil
        let script = "document.getElementById('\(anchor.jsStringLiteral)')?.scrollIntoView()"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    private static func guideURLs() -> (index: URL, readAccess: URL)? {
        guard let helpBundle = Bundle.main.url(forResource: "Savitar", withExtension: "help") else {
            return nil
        }
        let localeDir = helpBundle
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("en.lproj", isDirectory: true)
        let index = localeDir.appendingPathComponent("index.html")
        guard FileManager.default.fileExists(atPath: index.path) else { return nil }
        return (index, localeDir)
    }

    private func presentMissingGuideAlert() {
        let alert = NSAlert()
        alert.messageText = "Savitar Help is not available"
        alert.informativeText = """
        The help book was not found in this build. If you built from source, run:

        python3 client/scripts/build_help_book.py

        Then rebuild Savitar in Xcode.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

private extension String {
    /// Escape for safe embedding in a JavaScript single-quoted string literal.
    var jsStringLiteral: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }
}
