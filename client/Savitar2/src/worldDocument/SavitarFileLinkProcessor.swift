//
//  SavitarFileLinkProcessor.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Custom-scheme links for opening local capture/log files in Savitar text documents or the chosen capture editor.
enum SavitarFileLinkProcessor {
    static let scheme = "savitar-file"

    static func hrefURL(forFilePath path: String) -> String? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "open"
        components.queryItems = [URLQueryItem(name: "path", value: path)]
        return components.url?.absoluteString
    }

    static func filePath(from url: URL) -> String? {
        guard url.scheme?.lowercased() == scheme,
              url.host?.lowercased() == "open" else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "path" })?
            .value
    }

    static func statusHTML(heading: String, verb: String, path: String, linkColorHex: String?) -> String {
        let href = hrefURL(forFilePath: path) ?? path
        let escapedHref = XchCmdLinkProcessor.escapeAttribute(href)
        let escapedPath = XchCmdLinkProcessor.escapeText(path)
        let style = linkColorHex.map { " style=\"color: #\($0)\"" } ?? ""
        let escapedHeading = XchCmdLinkProcessor.escapeText(heading)
        let escapedVerb = XchCmdLinkProcessor.escapeText(verb)
        return """
        [SAVITAR] \(escapedHeading)<br>\(escapedVerb) <a href="\(escapedHref)"\(style)>\(escapedPath)</a><br>
        """
    }

    /// Opens a capture/log file in the app chosen under Settings → Input & Display (Story 24.5, v1 `LOGEDITOR_NAME`).
    /// Falls back to a Savitar text window when the editor is Savitar or the chosen app can't be found or launched.
    static func openFile(at path: String, prefs: AppPreferences = AppContext.shared.prefs) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let url = URL(fileURLWithPath: path)

        guard let appURL = editorApplicationURL(name: prefs.logEditorName, path: prefs.logEditorPath) else {
            openInSavitar(url)
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: configuration) { _, error in
            guard error != nil else { return }
            DispatchQueue.main.async { openInSavitar(url) }
        }
    }

    /// Resolves the capture editor app, or `nil` when captures should open in Savitar.
    /// A saved path wins; otherwise a bare app name (as imported from v1 prefs) is looked up in the usual app folders.
    static func editorApplicationURL(name: String,
                                     path: String,
                                     searchDirectories: [URL] = applicationSearchDirectories,
                                     fileManager: FileManager = .default) -> URL? {
        if !path.isEmpty {
            let url = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath)
            if fileManager.fileExists(atPath: url.path) {
                return isSavitar(url) ? nil : url
            }
        }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.caseInsensitiveCompare(AppPreferences.savitarLogEditorName) != .orderedSame else { return nil }

        let bundleName = trimmed.lowercased().hasSuffix(".app") ? trimmed : "\(trimmed).app"
        for directory in searchDirectories {
            let candidate = directory.appendingPathComponent(bundleName)
            if fileManager.fileExists(atPath: candidate.path) {
                return isSavitar(candidate) ? nil : candidate
            }
        }
        return nil
    }

    static var applicationSearchDirectories: [URL] {
        [
            "/Applications",
            "/Applications/Utilities",
            "/System/Applications",
            "/System/Applications/Utilities",
            "~/Applications"
        ].map { URL(fileURLWithPath: NSString(string: $0).expandingTildeInPath, isDirectory: true) }
    }

    private static func isSavitar(_ appURL: URL) -> Bool {
        guard let ownID = Bundle.main.bundleIdentifier,
              let bundleID = Bundle(url: appURL)?.bundleIdentifier else { return false }
        return bundleID == ownID
    }

    private static func openInSavitar(_ url: URL) {
        for document in NSDocumentController.shared.documents {
            guard document.fileURL == url else { continue }
            for controller in document.windowControllers {
                controller.window?.makeKeyAndOrderFront(nil)
            }
            return
        }

        NSDocumentController.shared.openDocument(withContentsOf: url,
                                                 display: true,
                                                 completionHandler: { _, _, _ in })
    }
}
