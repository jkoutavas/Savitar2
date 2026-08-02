//
//  MacroPopupOverlay.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//
//  Savitar 1.x origin: TVTooltip used by CTVVarPopup
//

import Cocoa

/// Yellow floating tooltip for macro type-ahead (same look as `ResolutionOverlay`).
final class MacroPopupOverlay {
    private static let paddingX: CGFloat = 8
    private static let paddingY: CGFloat = 4
    /// v1 idled every 15 ticks (~0.25s at 60 Hz).
    private static let blinkInterval: TimeInterval = 0.25

    private let panel: NSPanel
    private let container = NSView()
    private let label: NSTextField

    private var blinkTimer: Timer?
    private var blinkVisible = true
    private var currentText = ""
    private var currentOrigin = NSPoint.zero

    init() {
        label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.userFixedPitchFont(ofSize: 12) ?? NSFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.backgroundColor = .clear
        label.drawsBackground = false
        label.isBezeled = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center

        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 0.97, blue: 0.55, alpha: 1).cgColor
        container.layer?.borderColor = NSColor.black.cgColor
        container.layer?.borderWidth = 1
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor,
                                           constant: Self.paddingX),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor,
                                            constant: -Self.paddingX),
            label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor,
                                       constant: Self.paddingY),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor,
                                          constant: -Self.paddingY)
        ])

        panel = NSPanel(contentRect: .zero,
                        styleMask: [.borderless, .nonactivatingPanel],
                        backing: .buffered,
                        defer: false)
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.contentView = container
    }

    deinit {
        stopBlink()
    }

    func show(text: String, near point: NSPoint, in screen: NSScreen?, blink: Bool) {
        currentText = text
        label.stringValue = text
        layoutPanel(near: point, in: screen)
        panel.orderFrontRegardless()
        blinkVisible = true

        if blink {
            startBlink()
        } else {
            stopBlink()
        }
    }

    func hide() {
        stopBlink()
        panel.orderOut(nil)
    }

    // MARK: - Private

    private func layoutPanel(near point: NSPoint, in screen: NSScreen?) {
        let textSize = label.intrinsicContentSize
        let size = NSSize(width: ceil(textSize.width) + Self.paddingX * 2,
                          height: ceil(textSize.height) + Self.paddingY * 2)
        container.setFrameSize(size)
        panel.setContentSize(size)

        let screen = screen ?? NSScreen.main
        var origin = point
        origin.x -= panel.frame.width / 2
        origin.y += 18
        if let screen {
            let visible = screen.visibleFrame
            origin.x = min(max(origin.x, visible.minX + 4), visible.maxX - panel.frame.width - 4)
            origin.y = min(max(origin.y, visible.minY + 4), visible.maxY - panel.frame.height - 4)
        }
        currentOrigin = origin
        panel.setFrameOrigin(origin)
    }

    private func startBlink() {
        stopBlink()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: Self.blinkInterval, repeats: true) { [weak self] _ in
            self?.toggleBlink()
        }
        if let blinkTimer {
            RunLoop.main.add(blinkTimer, forMode: .common)
        }
    }

    private func stopBlink() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        blinkVisible = true
    }

    private func toggleBlink() {
        blinkVisible.toggle()
        if blinkVisible {
            label.stringValue = currentText
            panel.setFrameOrigin(currentOrigin)
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }
}
