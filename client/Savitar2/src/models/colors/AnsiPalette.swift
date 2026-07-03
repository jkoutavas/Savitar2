//
//  AnsiPalette.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import AppKit

// The eight ANSI base hues, in SGR order (30-37 / 40-47).
enum AnsiColorName: String, CaseIterable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white

    // The SGR foreground index (30-37) this hue maps to.
    var index: Int {
        AnsiColorName.allCases.firstIndex(of: self) ?? 0
    }

    var title: String {
        rawValue.capitalized
    }
}

// Savitar 1 stored three shades per hue, distinguished by a name suffix:
// the base name ("red"), a dim variant ("redd"), and an intense variant ("redi").
enum AnsiColorShade: String, CaseIterable {
    case normal = ""
    case dim = "d"
    case intense = "i"

    var title: String {
        switch self {
        case .normal: return "Normal"
        case .dim: return "Dim"
        case .intense: return "Intense"
        }
    }
}

enum AnsiPalette {
    // Full "name -> hex" default table, matching Savitar 1's CreateColorPreferences().
    static let defaultHex: [String: String] = [
        "black": "#000000", "blackd": "#616161", "blacki": "#000000",
        "red": "#B00707", "redd": "#AC0707", "redi": "#DC0707",
        "green": "#00A51D", "greend": "#008E2F", "greeni": "#23D916",
        "yellow": "#E6B319", "yellowd": "#D6A309", "yellowi": "#FAF305",
        "blue": "#4D00B4", "blued": "#00009F", "bluei": "#0000FA",
        "magenta": "#B000A1", "magentad": "#A00090", "magentai": "#F30785",
        "cyan": "#00B0B0", "cyand": "#0090A0", "cyani": "#02ABEB",
        "white": "#FFFFFF", "whited": "#BFBFBF", "whitei": "#FFFFFF"
    ]

    // The stored color name for a given hue + shade, e.g. (.red, .dim) -> "redd".
    static func name(for hue: AnsiColorName, shade: AnsiColorShade) -> String {
        "\(hue.rawValue)\(shade.rawValue)"
    }

    // Every stored color name, hue-major then shade (normal, dim, intense).
    static var allNames: [String] {
        AnsiColorName.allCases.flatMap { hue in
            AnsiColorShade.allCases.map { name(for: hue, shade: $0) }
        }
    }

    static func defaultColor(named name: String) -> NSColor {
        guard let hex = defaultHex[name], let color = NSColor(hex: hex) else {
            return .black
        }
        return color
    }
}
