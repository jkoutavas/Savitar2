//
//  ClickerAppearance.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Savitar 1 Macro Clicker palette — vector recreation of v1 cicn whimsy (Story 11).
enum ClickerAppearance {
    static let panelGray = NSColor(srgbRed: 186 / 255, green: 186 / 255, blue: 186 / 255, alpha: 1)
    static let gridLine = NSColor(calibratedWhite: 0.82, alpha: 1)

    // Sampled from v1 close-up crop (user image 2). Arrows and labels use different greens.
    private enum Reference {
        /// Compass wedge fill — periwinkle mode `#6766CE`.
        static let compassBody = NSColor(srgbRed: 103 / 255, green: 102 / 255, blue: 206 / 255, alpha: 1)
        /// Compass pressed — lightened body.
        static let compassPressed = NSColor(srgbRed: 140 / 255, green: 139 / 255, blue: 218 / 255, alpha: 1)
        /// Compass outline — dark blue-purple from wedge edges.
        static let compassOutline = NSColor(srgbRed: 46 / 255, green: 46 / 255, blue: 67 / 255, alpha: 1)
        /// Up/down arrows — warmer grass green (`#52996B`).
        static let arrowGreen = NSColor(srgbRed: 82 / 255, green: 153 / 255, blue: 107 / 255, alpha: 1)
        /// Grid labels — cooler teal-leaning green (`#52986D`).
        static let labelGreen = NSColor(srgbRed: 82 / 255, green: 152 / 255, blue: 109 / 255, alpha: 1)
        /// Pressed green — arrow_down median.
        static let greenPressed = NSColor(srgbRed: 80 / 255, green: 148 / 255, blue: 106 / 255, alpha: 1)
        /// Grid pressed — lighter mint highlight.
        static let greenHighlight = NSColor(srgbRed: 89 / 255, green: 156 / 255, blue: 116 / 255, alpha: 1)
    }

    static let directionDark = Reference.compassBody
    static let directionLight = Reference.compassPressed
    static let directionOutline = Reference.compassOutline
    static let verticalFill = Reference.arrowGreen
    static let verticalPressed = Reference.greenPressed
    static let verticalStroke = NSColor.black
    static let labelFill = Reference.labelGreen

    static func drawDirectionArrow(in rect: NSRect, slot: ClickerSlotID, pressed: Bool) {
        let drawRect = rect.insetBy(dx: -1.5, dy: -1.5)

        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let center = CGPoint(x: drawRect.midX, y: drawRect.midY)
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: directionRotation(for: slot))
        context.translateBy(x: -center.x, y: -center.y)

        let path = canonicalDirectionPath(in: drawRect)
        (pressed ? directionLight : directionDark).setFill()
        path.fill()
        directionOutline.setStroke()
        path.lineWidth = 0.55
        path.lineJoinStyle = .miter
        path.stroke()
    }

    /// One isosceles wedge rotated per slot — matches v1 uniform compass triangles.
    private static func directionRotation(for slot: ClickerSlotID) -> CGFloat {
        switch slot {
        case .north: return 0
        case .northeast: return .pi / 4
        case .east: return .pi / 2
        case .southeast: return 3 * .pi / 4
        case .south: return .pi
        case .southwest: return -3 * .pi / 4
        case .west: return -.pi / 2
        case .northwest: return -.pi / 4
        default: return 0
        }
    }

    /// Canonical north-pointing wedge; bases meet near the rose center (8, 8).
    private static func canonicalDirectionPath(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: map(CGPoint(x: 8, y: 15), in: rect))
        path.line(to: map(CGPoint(x: 4, y: 8), in: rect))
        path.line(to: map(CGPoint(x: 12, y: 8), in: rect))
        path.close()
        return path
    }

    static func drawVerticalArrow(in rect: NSRect, up: Bool, pressed: Bool) {
        let inset = rect.insetBy(dx: 1.5, dy: 1.5)
        let path = verticalArrowPath(up: up, in: inset)
        let fill = pressed ? verticalPressed : verticalFill
        fill.setFill()
        path.fill()
        verticalStroke.setStroke()
        path.lineWidth = 1.0
        path.lineJoinStyle = .miter
        path.stroke()
    }

    /// Chunky tailed arrow traced from Savitar 1 16×16 KPup/KPdown proportions.
    private static func verticalArrowPath(up: Bool, in rect: NSRect) -> NSBezierPath {
        let points: [CGPoint]
        if up {
            points = [
                CGPoint(x: 8, y: 15),
                CGPoint(x: 13, y: 9),
                CGPoint(x: 10, y: 9),
                CGPoint(x: 10, y: 1),
                CGPoint(x: 6, y: 1),
                CGPoint(x: 6, y: 9),
                CGPoint(x: 3, y: 9)
            ]
        } else {
            points = [
                CGPoint(x: 8, y: 1),
                CGPoint(x: 13, y: 7),
                CGPoint(x: 10, y: 7),
                CGPoint(x: 10, y: 15),
                CGPoint(x: 6, y: 15),
                CGPoint(x: 6, y: 7),
                CGPoint(x: 3, y: 7)
            ]
        }

        let path = NSBezierPath()
        path.move(to: map(points[0], in: rect))
        for point in points.dropFirst() {
            path.line(to: map(point, in: rect))
        }
        path.close()
        return path
    }

    static func drawGridPanel(in rect: NSRect, columns: Int, rows: Int) {
        panelGray.setFill()
        rect.fill()

        gridLine.setStroke()
        let path = NSBezierPath()
        path.lineWidth = 1

        let cellWidth = rect.width / CGFloat(columns)
        let cellHeight = rect.height / CGFloat(rows)

        path.appendRect(rect)

        for column in 1..<columns {
            let x = rect.minX + CGFloat(column) * cellWidth
            path.move(to: NSPoint(x: x, y: rect.minY))
            path.line(to: NSPoint(x: x, y: rect.maxY))
        }
        for row in 1..<rows {
            let y = rect.minY + CGFloat(row) * cellHeight
            path.move(to: NSPoint(x: rect.minX, y: y))
            path.line(to: NSPoint(x: rect.maxX, y: y))
        }
        path.stroke()
    }

    static func drawGridCell(in rect: NSRect, label: String, pressed: Bool) {
        if pressed {
            Reference.greenHighlight.setFill()
            rect.fill()
        }
        drawWhimsicalLabel(label, in: rect)
    }

    static func drawWhimsicalLabel(_ text: String, in rect: NSRect) {
        let fontSize = min(rect.width, rect.height) * 0.90
        let font = whimsicalFont(size: fontSize)
        let tilt = whimsicalTilt(for: text)
        let nudge = whimsicalNudge(for: text)

        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.translateBy(x: rect.midX, y: rect.midY)
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0.12, d: 1, tx: 0, ty: 0))
        context.rotate(by: tilt)
        context.translateBy(x: -rect.midX, y: -rect.midY)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: labelFill,
            .strokeColor: NSColor.black,
            .strokeWidth: -6.0
        ]
        let rendered = NSAttributedString(string: text, attributes: attrs)
        let textSize = rendered.size()
        let origin = NSPoint(
            x: rect.midX - textSize.width / 2 + nudge.x,
            y: rect.midY - textSize.height / 2 + nudge.y
        )
        rendered.draw(at: origin)
    }

    static func whimsicalFont(size: CGFloat) -> NSFont {
        if let font = NSFont(name: "Arial-BoldItalicMT", size: size) {
            return font
        }
        if let font = NSFont(name: "Arial-BoldMT", size: size) {
            return NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask) ?? font
        }
        let base = NSFont.boldSystemFont(ofSize: size)
        return NSFontManager.shared.convert(base, toHaveTrait: .italicFontMask) ?? base
    }

    /// Tiny per-label rotation (radians) for hand-drawn irregularity.
    private static func whimsicalTilt(for label: String) -> CGFloat {
        let tilts: [String: CGFloat] = [
            "1": 0.03, "2": -0.02, "3": 0.04, "4": -0.03, "5": 0.02,
            "6": -0.04, "7": 0.05, "8": -0.02, "9": 0.03,
            "a": -0.06, "b": 0.04, "c": -0.03, "d": 0.05, "e": -0.04, "f": 0.06
        ]
        return tilts[label] ?? 0
    }

    private static func whimsicalNudge(for label: String) -> NSPoint {
        let nudges: [String: NSPoint] = [
            "1": NSPoint(x: 0, y: 1), "2": NSPoint(x: 1, y: 0), "3": NSPoint(x: -1, y: 1),
            "4": NSPoint(x: 0, y: -1), "5": NSPoint(x: 1, y: 1), "6": NSPoint(x: -1, y: 0),
            "7": NSPoint(x: 0, y: 1), "8": NSPoint(x: 1, y: -1), "9": NSPoint(x: -1, y: 1),
            "a": NSPoint(x: 1, y: 0), "b": NSPoint(x: -1, y: 1), "c": NSPoint(x: 0, y: -1),
            "d": NSPoint(x: 1, y: 1), "e": NSPoint(x: -1, y: 0), "f": NSPoint(x: 0, y: 1)
        ]
        return nudges[label] ?? .zero
    }

    static func whimsicalLabel(_ text: String, size: CGFloat) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: whimsicalFont(size: size),
            .foregroundColor: labelFill,
            .strokeColor: NSColor.black,
            .strokeWidth: -6.0
        ])
    }

    /// Map 16×16 icon coordinates (origin bottom-left) into a flipped view rect.
    private static func map(_ point: CGPoint, in rect: NSRect) -> NSPoint {
        NSPoint(
            x: rect.minX + (point.x / 16) * rect.width,
            y: rect.maxY - (point.y / 16) * rect.height
        )
    }
}
