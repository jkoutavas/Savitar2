//
//  AppAppearance.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// App-wide chrome appearance — independent of per-world session colors (Story 26).
enum AppAppearanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var menuTitle: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var xmlValue: String {
        switch self {
        case .system: return "SYSTEM"
        case .light: return "LIGHT"
        case .dark: return "DARK"
        }
    }

    static func from(xmlValue: String) -> AppAppearanceMode? {
        switch xmlValue.uppercased() {
        case "SYSTEM": return .system
        case "LIGHT": return .light
        case "DARK": return .dark
        default: return nil
        }
    }

    var nsAppearance: NSAppearance? {
        switch self {
        case .system:
            return nil
        case .light:
            return NSAppearance(named: .aqua)
        case .dark:
            return NSAppearance(named: .darkAqua)
        }
    }
}

enum AppAppearance {
    static func apply(_ mode: AppAppearanceMode) {
        guard !isRunningTests else { return }

        NSApp.appearance = mode.nsAppearance
        for window in NSApp.windows {
            window.appearance = nil
            window.contentView?.needsDisplay = true
            window.contentView?.layoutSubtreeIfNeeded()
        }
        NotificationCenter.default.post(name: .savitarAppearanceChanged, object: nil)
    }
}

extension Notification.Name {
    static let savitarAppearanceChanged = Notification.Name("savitarAppearanceChanged")
}
