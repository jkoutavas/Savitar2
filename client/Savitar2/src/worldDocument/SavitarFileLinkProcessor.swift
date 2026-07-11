//
//  SavitarFileLinkProcessor.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Custom-scheme links for opening local capture/log files in Savitar text documents.
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

    static func openFile(at path: String) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let url = URL(fileURLWithPath: path)

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
