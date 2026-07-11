//
//  SessionStatusBarView.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// One-line v1-style status strip for the output or input pane.
final class SessionStatusBarView: NSView {
    private let backgroundFill = NSView()
    private let label = NSTextField(labelWithString: "")
    private var heightConstraint: NSLayoutConstraint!
    private var visibleHeight: CGFloat = 14

    var isStatusVisible: Bool {
        !isHidden
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func apply(world: World) {
        let font = NSFont(name: world.fontName, size: world.fontSize) ?? NSFont.systemFont(ofSize: world.fontSize)
        label.font = font
        // Invert session fore/back so the status strip stands out from the panes.
        let fillColor = world.foreColor
        let textColor = world.backColor
        label.textColor = textColor
        label.backgroundColor = fillColor
        backgroundFill.layer?.backgroundColor = fillColor.cgColor
        layer?.backgroundColor = fillColor.cgColor
        visibleHeight = Self.pixelAlignedHeight(
            max(PaneDimensions.lineHeight(for: font), 12)
        )
        if isStatusVisible {
            heightConstraint.constant = visibleHeight
        }
    }

    func setText(_ text: String) {
        label.stringValue = text
        isHidden = false
        heightConstraint.constant = visibleHeight
    }

    func clear() {
        label.stringValue = ""
        isHidden = true
        heightConstraint.constant = 0
    }

    private func configure() {
        wantsLayer = true
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        backgroundFill.wantsLayer = true
        backgroundFill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundFill)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.alignment = .left
        label.drawsBackground = true
        label.isBordered = false
        addSubview(label)

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            heightConstraint,
            backgroundFill.topAnchor.constraint(equalTo: topAnchor),
            backgroundFill.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundFill.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundFill.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private static func pixelAlignedHeight(_ height: CGFloat) -> CGFloat {
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        return ceil(height * scale) / scale
    }
}
