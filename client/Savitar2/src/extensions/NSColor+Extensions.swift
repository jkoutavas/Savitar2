//
//  NSColor+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/25/18.
//  based on https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift
//

import AppKit

extension NSColor {
    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From cgColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components else {
            return nil
        }

        var r: Float = 0.0
        var g: Float = 0.0
        var b: Float = 0.0
        var a: Float = 1.0

        if components.count == 2 {
            r = Float(components[0])
            g = Float(components[0])
            b = Float(components[0])
            a = Float(components[1])
        } else if components.count >= 3 {
            r = Float(components[0])
            g = Float(components[1])
            b = Float(components[2])
        }
        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX",
                lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX",
                lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
