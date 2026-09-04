//
//  SavitarHelp.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// In-app user guide (Story 16).
///
/// Opens the bundled HTML help book in a Savitar window. We intentionally do **not**
/// route Help → Savitar Help through macOS Help Viewer (`NSHelpManager`): `helpd`
/// often fails for apps run from Xcode (or outside `/Applications`), which surfaces
/// “The selected content is currently unavailable.” The bundled `.help` book remains
/// in the app for a future `registerBooks` integration and Story 17 anchors.
enum SavitarHelp {
    /// Title passed to `NSHelpManager` if Apple Help Viewer integration is added later.
    static let bookName = "Savitar Help"

    /// Stable anchors for Story 17 contextual help. Generated from USER_GUIDE.md section titles.
    enum Anchor {
        static let home = "top"
        static let gettingStarted = "getting-started"
        static let installUpdates = "install-updates"
        static let speech = "speech"
        static let ansiColors = "ansi-colors"
        static let inputDisplay = "input-display"
        static let audio = "audio"
        static let updates = "updates"
        static let startup = "startup"
        static let settingsAdvanced = "settings-advanced"
        static let menus = "menus"
        static let sessionWindow = "session-window"
        static let events = "events"
        static let macros = "macros"
        static let macrosMacroClicker = "macros-macro-clicker"
        static let enteringCommands = "entering-commands"
        static let variablesExpansion = "variables-expansion"
        static let localCommands = "local-commands"
        static let triggers = "triggers"
        static let outputAppearance = "output-appearance"
        static let worldsConnection = "worlds-connection"
        static let worldsConnectionWorldPicker = "worlds-connection-world-picker"
        static let worldsConnectionOpeningTelnetLinks = "worlds-connection-opening-telnet-links"
        static let settingsReference = "settings-reference"
        static let tipsTroubleshooting = "tips-troubleshooting"
        static let glossary = "glossary"
        static let worldSettings = "world-settings"
        static let worldSettingsStarting = "world-settings-starting-tab"
        static let worldSettingsAppearance = "world-settings-appearance-tab"
        static let worldSettingsInput = "world-settings-input-tab"
        static let worldSettingsOutput = "world-settings-output-tab"
        static let worldSettingsClosing = "world-settings-closing-tab"
        static let privacy = "privacy"
        static let gettingHelp = "getting-help"
        static let planned = "planned"

        /// Subsections (h3) for contextual help — prefixed by parent chapter in the help book HTML.
        static let speechSettingsReference = "speech-speech-settings-reference"
        static let menusAudioMenu = "menus-audio-menu"
        static let savitarMenu = "menus-savitar-menu"
        static let worldMenu = "menus-world-menu"
    }

    /// World Settings sheet tabs (storyboard order). Maps to guide h3 anchors under `#world-settings`.
    enum WorldSettingsTab: Int, CaseIterable {
        case starting = 0
        case appearance = 1
        case input = 2
        case output = 3
        case closing = 4

        var title: String {
            switch self {
            case .starting: return "Starting"
            case .appearance: return "Appearance"
            case .input: return "Input"
            case .output: return "Output"
            case .closing: return "Closing"
            }
        }

        var helpAnchor: String {
            switch self {
            case .starting: return Anchor.worldSettingsStarting
            case .appearance: return Anchor.worldSettingsAppearance
            case .input: return Anchor.worldSettingsInput
            case .output: return Anchor.worldSettingsOutput
            case .closing: return Anchor.worldSettingsClosing
            }
        }

        var helpToolTip: String {
            switch self {
            case .starting:
                return "Open help for host, port, and startup commands"
            case .appearance:
                return "Open help for fonts, colors, and ANSI/HTML options"
            case .input:
                return "Open help for echo, markers, and line endings"
            case .output:
                return "Open help for session logging"
            case .closing:
                return "Open help for logoff command on close"
            }
        }
    }

    /// Help → Savitar Help (⌘?) and contextual `?` buttons.
    static func show(anchor: String? = nil) {
        let target = anchor?.isEmpty == false ? anchor! : Anchor.home
        HelpGuideWindowController.shared.show(anchor: target)
    }
}
