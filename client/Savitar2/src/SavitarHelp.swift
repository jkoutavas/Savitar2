//
//  SavitarHelp.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// In-app user guide (Story 16). Opens the bundled Apple Help book or a local HTML fallback.
enum SavitarHelp {
    /// Must match `CFBundleHelpBookName` in Info.plist and `HPDBookTitle` in the help bundle.
    static let bookName = "Savitar Help"

    /// Stable anchors for Story 17 contextual help. Generated from USER_GUIDE.md section titles.
    enum Anchor {
        static let home = "top"
        static let gettingStarted = "getting-started"
        static let speech = "speech"
        static let menus = "menus"
        static let events = "events"
        static let macros = "macros"
        static let worldSettings = "world-settings"
        static let privacy = "privacy"
        static let gettingHelp = "getting-help"
        static let planned = "planned"
    }

    /// Help → Savitar Help (⌘?) and future contextual `?` buttons.
    static func show(anchor: String? = nil) {
        let target = anchor?.isEmpty == false ? anchor! : Anchor.home
        guard Bundle.main.url(forResource: "Savitar", withExtension: "help") != nil else {
            HelpGuideWindowController.shared.show(anchor: target)
            return
        }
        NSHelpManager.shared.openHelpAnchor(target, inBook: bookName)
    }
}
