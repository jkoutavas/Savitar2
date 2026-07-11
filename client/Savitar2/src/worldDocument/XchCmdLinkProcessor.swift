//
//  XchCmdLinkProcessor.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

/// Converts Pueblo-style `<a xch_cmd="…">` tags into navigable custom-scheme links for WebKit.
enum XchCmdLinkProcessor {
    static let scheme = "savitar-xch"

    private static let anchorPattern = try? NSRegularExpression(
        pattern: #"<a\s+([^>]*?\bxch_cmd\s*=\s*"([^"]*)"[^>]*)>"#,
        options: [.caseInsensitive]
    )

    private static let hintPattern = try? NSRegularExpression(
        pattern: #"\bxch_hint\s*=\s*"([^"]*)""#,
        options: [.caseInsensitive]
    )

    static func process(_ html: String) -> String {
        guard html.range(of: "xch_cmd", options: .caseInsensitive) != nil,
              let anchorPattern else { return html }

        let nsHTML = html as NSString
        let matches = anchorPattern.matches(in: html, options: [], range: NSRange(location: 0, length: nsHTML.length))
        guard !matches.isEmpty else { return html }

        var result = html
        for match in matches.reversed() {
            guard match.numberOfRanges >= 3,
                  let fullRange = Range(match.range, in: result),
                  let attrsRange = Range(match.range(at: 1), in: html),
                  let cmdRange = Range(match.range(at: 2), in: html) else { continue }

            let attrs = String(html[attrsRange])
            let command = String(html[cmdRange])
            guard let href = hrefURL(for: command) else { continue }

            var newAttrs = attrs
            if !attrs.lowercased().contains("href=") {
                newAttrs += " href=\"\(href)\""
            }
            if !attrs.lowercased().contains("title="),
               let hint = xchHint(in: attrs) {
                newAttrs += " title=\"\(escapeAttribute(hint))\""
            }
            result.replaceSubrange(fullRange, with: "<a \(newAttrs)>")
        }
        return result
    }

    static func hrefURL(for command: String) -> String? {
        var components = URLComponents()
        components.scheme = scheme
        components.path = "/" + command
        return components.url?.absoluteString
    }

    static func command(from url: URL) -> String? {
        guard url.scheme?.lowercased() == scheme else { return nil }
        guard !url.path.isEmpty else { return "" }
        let raw = url.path.hasPrefix("/") ? String(url.path.dropFirst()) : url.path
        return raw.removingPercentEncoding ?? raw
    }

    private static func xchHint(in attrs: String) -> String? {
        guard let hintPattern else { return nil }
        let nsAttrs = attrs as NSString
        guard let match = hintPattern.firstMatch(in: attrs,
                                                 options: [],
                                                 range: NSRange(location: 0, length: nsAttrs.length)),
              match.numberOfRanges >= 2,
              let hintRange = Range(match.range(at: 1), in: attrs) else { return nil }
        return String(attrs[hintRange])
    }

    static func escapeAttribute(_ value: String) -> String {
        return value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }

    static func escapeText(_ value: String) -> String {
        return value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
