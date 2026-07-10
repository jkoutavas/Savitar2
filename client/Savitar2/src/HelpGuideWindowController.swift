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

    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
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
        window.contentView = webView
        webView.navigationDelegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
