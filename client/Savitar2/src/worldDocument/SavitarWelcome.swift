//
//  SavitarWelcome.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

/// Opening banner shown at the top of each world session output pane (Savitar 1 tradition).
enum SavitarWelcome {
    static let websiteURL = "https://www.heynow.com/savitar"
    static let titleLine = "Welcome to Savitar"
    static let rightsLine = "All rights reserved."

    static func helpHint(commandMarker: String) -> String {
        return " — type \(commandMarker)help for a list of local commands"
    }

    static func headerLine(commandMarker: String) -> String {
        return titleLine + helpHint(commandMarker: commandMarker)
    }

    static var versionLine: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2"
        return "\(version) Copyright © 1996-2026, Heynow Software"
    }

    static func html(commandMarker: String, linkColorHex: String?) -> String {
        let hint = escape(helpHint(commandMarker: commandMarker))
        let href = XchCmdLinkProcessor.escapeAttribute(websiteURL)
        let url = escape(websiteURL)
        let linkStyle = linkColorHex.map { " style=\"color: #\($0)\"" } ?? ""
        return """
        <div class="savitar-welcome"><strong>\(titleLine)</strong>\(hint)<br>\
        \(escape(versionLine))<br><a href="\(href)"\(linkStyle)>\(url)</a><br>\
        \(escape(rightsLine))<br><br></div>
        """
    }

    private static func escape(_ value: String) -> String {
        return XchCmdLinkProcessor.escapeText(value)
    }
}
