//
//  ClickerContentViewController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

private struct ClickerCompassPlacement {
    let slot: ClickerSlotID
    let col: Int
    let row: Int
}

/// Macro Clicker palette — Savitar 1 whimsical compass, up/down, and macro grid (Story 11).
final class ClickerContentViewController: NSViewController {
    /// Slightly wider than the 200pt v1 palette so the title bar fits **Macro Clicker** + contextual **?**.
    static let designedContentSize = NSSize(width: 228, height: 440)
    /// Layout constants in `buildLayout()` were tuned for this v1 content width.
    private static let legacyContentWidth: CGFloat = 200
    private static var layoutScale: CGFloat { designedContentSize.width / legacyContentWidth }
    private static func scaled(_ value: CGFloat) -> CGFloat { (value * layoutScale).rounded() }
    private static let captionAreaMinHeight: CGFloat = 80

    private let captionField: NSTextField = {
        let field = NSTextField(wrappingLabelWithString: "")
        field.lineBreakMode = .byWordWrapping
        field.font = NSFont.boldSystemFont(ofSize: ClickerContentViewController.scaled(11))
        field.textColor = NSColor(calibratedWhite: 0.12, alpha: 1)
        field.alignment = .center
        field.maximumNumberOfLines = 2
        field.cell?.truncatesLastVisibleLine = true
        field.cell?.wraps = true
        field.cell?.isScrollable = false
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return field
    }()
    private var slotButtons: [ClickerSlotID: ClickerPaletteButton] = [:]

    override func loadView() {
        let root = ClickerRootView(frame: NSRect(origin: .zero, size: Self.designedContentSize))
        root.clipsToBounds = true
        root.autoresizingMask = [.width, .height]
        view = root
        buildLayout()
    }

    func refreshCaption(for slot: ClickerSlotID? = nil, fixedMacro: String? = nil) {
        if let fixedMacro {
            setCaption(MacroClicker.caption(for: fixedMacro, session: MacroClicker.frontmostSession()))
        } else if let slot {
            let name = AppContext.shared.prefs.clickerMan.slot(for: slot).macroName
            setCaption(MacroClicker.caption(for: name, session: MacroClicker.frontmostSession()))
        } else {
            setCaption("")
        }
    }

    private func setCaption(_ text: String) {
        captionField.stringValue = text
        let baseFont = NSFont.boldSystemFont(ofSize: Self.scaled(11))
        if text == MacroClicker.undefinedCaption {
            captionField.font = NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask)
        } else {
            captionField.font = baseFont
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        redisplayPalette()
    }

    func redisplayPalette() {
        view.needsDisplay = true
        redisplaySubviews(of: view)
    }

    private func redisplaySubviews(of view: NSView) {
        for subview in view.subviews {
            subview.needsDisplay = true
            redisplaySubviews(of: subview)
        }
    }

    private func buildLayout() {
        let compassSize = Self.scaled(30)
        let compassOverlap = Self.scaled(13)
        let compassStepH = compassSize - compassOverlap
        let compassStepV = compassSize - compassOverlap
        let verticalSize = NSSize(width: Self.scaled(36), height: Self.scaled(28))
        let verticalGap = Self.scaled(2)
        // Slightly shorter than uniform scale so compass + grid still fit the fixed window height.
        let gridCell = NSSize(width: Self.scaled(56), height: Self.scaled(48) - 2)
        let topInset = Self.scaled(10)
        let controlsGridGap = Self.scaled(8)
        let compassVerticalGap = Self.scaled(8)

        let compassPanel = ClickerCompassPanel()
        compassPanel.translatesAutoresizingMaskIntoConstraints = false

        let topControlsPanel = NSView()
        topControlsPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topControlsPanel)
        topControlsPanel.addSubview(compassPanel)

        let compassLayout: [ClickerCompassPlacement] = [
            ClickerCompassPlacement(slot: .northwest, col: 0, row: 0),
            ClickerCompassPlacement(slot: .north, col: 1, row: 0),
            ClickerCompassPlacement(slot: .northeast, col: 2, row: 0),
            ClickerCompassPlacement(slot: .west, col: 0, row: 1),
            ClickerCompassPlacement(slot: .east, col: 2, row: 1),
            ClickerCompassPlacement(slot: .southwest, col: 0, row: 2),
            ClickerCompassPlacement(slot: .south, col: 1, row: 2),
            ClickerCompassPlacement(slot: .southeast, col: 2, row: 2)
        ]

        for placement in compassLayout {
            let button = makeDirectionButton(slot: placement.slot)
            slotButtons[placement.slot] = button
            compassPanel.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: compassSize),
                button.heightAnchor.constraint(equalToConstant: compassSize),
                button.leadingAnchor.constraint(
                    equalTo: compassPanel.leadingAnchor,
                    constant: CGFloat(placement.col) * compassStepH
                ),
                button.topAnchor.constraint(
                    equalTo: compassPanel.topAnchor,
                    constant: CGFloat(placement.row) * compassStepV
                )
            ])
        }

        compassPanel.configure(
            placements: compassLayout.map { placement in
                ClickerCompassPanel.Placement(
                    slot: placement.slot,
                    frame: NSRect(
                        x: CGFloat(placement.col) * compassStepH,
                        y: CGFloat(placement.row) * compassStepV,
                        width: compassSize,
                        height: compassSize
                    )
                )
            }
        )
        compassPanel.onHoverSlot = { [weak self] slot in
            if let slot {
                self?.refreshCaption(for: slot)
            } else {
                self?.refreshCaption(for: nil)
            }
        }

        let upButton = makeVerticalButton(up: true)
        let downButton = makeVerticalButton(up: false)
        topControlsPanel.addSubview(upButton)
        topControlsPanel.addSubview(downButton)

        let gridPanel = ClickerGridPanel(columns: 3, rows: 5)
        gridPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridPanel)

        for (index, slot) in ClickerSlotID.gridSlots.enumerated() {
            let col = index % 3
            let row = index / 3
            let button = makeGridButton(slot: slot)
            slotButtons[slot] = button
            gridPanel.addSubview(button)
            NSLayoutConstraint.activate(
                gridConstraints(for: button, col: col, row: row, gridPanel: gridPanel, gridCell: gridCell)
            )
        }

        let captionPanel = NSView()
        captionPanel.translatesAutoresizingMaskIntoConstraints = false
        captionPanel.clipsToBounds = true
        view.addSubview(captionPanel)
        captionPanel.addSubview(captionField)

        let compassWidth = compassSize + compassStepH * 2
        let compassHeight = compassSize + compassStepV * 2
        let gridWidth = gridCell.width * 3
        let gridHeight = gridCell.height * 5

        let controlsWidth = compassWidth + compassVerticalGap + verticalSize.width
        let controlsHeight = max(compassHeight, verticalSize.height * 2 + verticalGap)

        NSLayoutConstraint.activate([
            topControlsPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topControlsPanel.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset),
            topControlsPanel.widthAnchor.constraint(equalToConstant: controlsWidth),
            topControlsPanel.heightAnchor.constraint(equalToConstant: controlsHeight),

            compassPanel.leadingAnchor.constraint(equalTo: topControlsPanel.leadingAnchor),
            compassPanel.topAnchor.constraint(equalTo: topControlsPanel.topAnchor),
            compassPanel.widthAnchor.constraint(equalToConstant: compassWidth),
            compassPanel.heightAnchor.constraint(equalToConstant: compassHeight),

            upButton.leadingAnchor.constraint(equalTo: compassPanel.trailingAnchor, constant: compassVerticalGap),
            upButton.topAnchor.constraint(equalTo: topControlsPanel.topAnchor),
            upButton.widthAnchor.constraint(equalToConstant: verticalSize.width),
            upButton.heightAnchor.constraint(equalToConstant: verticalSize.height),

            downButton.leadingAnchor.constraint(equalTo: upButton.leadingAnchor),
            downButton.topAnchor.constraint(equalTo: upButton.bottomAnchor, constant: verticalGap),
            downButton.widthAnchor.constraint(equalToConstant: verticalSize.width),
            downButton.heightAnchor.constraint(equalToConstant: verticalSize.height),

            gridPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridPanel.topAnchor.constraint(equalTo: topControlsPanel.bottomAnchor, constant: controlsGridGap),
            gridPanel.widthAnchor.constraint(equalToConstant: gridWidth),
            gridPanel.heightAnchor.constraint(equalToConstant: gridHeight),

            captionPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captionPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captionPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            captionPanel.heightAnchor.constraint(equalToConstant: Self.captionAreaMinHeight),

            captionField.leadingAnchor.constraint(equalTo: captionPanel.leadingAnchor, constant: 6),
            captionField.trailingAnchor.constraint(equalTo: captionPanel.trailingAnchor, constant: -6),
            captionField.centerYAnchor.constraint(equalTo: captionPanel.centerYAnchor),
            captionField.topAnchor.constraint(greaterThanOrEqualTo: captionPanel.topAnchor, constant: 8),
            captionField.bottomAnchor.constraint(lessThanOrEqualTo: captionPanel.bottomAnchor, constant: -8)
        ])
    }

    private func gridConstraints(
        for view: NSView,
        col: Int,
        row: Int,
        gridPanel: NSView,
        gridCell: NSSize
    ) -> [NSLayoutConstraint] {
        [
            view.widthAnchor.constraint(equalToConstant: gridCell.width),
            view.heightAnchor.constraint(equalToConstant: gridCell.height),
            view.leadingAnchor.constraint(
                equalTo: gridPanel.leadingAnchor,
                constant: CGFloat(col) * gridCell.width
            ),
            view.topAnchor.constraint(
                equalTo: gridPanel.topAnchor,
                constant: CGFloat(row) * gridCell.height
            )
        ]
    }

    private func makeDirectionButton(slot: ClickerSlotID) -> ClickerPaletteButton {
        let button = ClickerPaletteButton(frame: .zero)
        button.style = .direction(slot)
        button.slotID = slot
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = "⌘-click to bind macro"
        button.onClick = { [weak self] in
            guard let self else { return }
            if NSApp.currentEvent?.modifierFlags.contains(.command) == true {
                bindSlot(slot)
                return
            }
            let macroName = AppContext.shared.prefs.clickerMan.slot(for: slot).macroName
            MacroClicker.sendMacro(named: macroName)
        }
        return button
    }

    private func makeVerticalButton(up: Bool) -> ClickerPaletteButton {
        let button = ClickerPaletteButton(frame: .zero)
        button.style = .vertical(up: up)
        wireButton(button, hover: { [weak self] in
            self?.refreshCaption(fixedMacro: up ? "MACRO_UP" : "MACRO_DOWN")
        }, click: {
            MacroClicker.sendMacro(named: up ? "MACRO_UP" : "MACRO_DOWN")
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = up ? "Up" : "Down"
        return button
    }

    private func makeGridButton(slot: ClickerSlotID) -> ClickerPaletteButton {
        let button = ClickerPaletteButton(frame: .zero)
        button.style = .grid(label: slot.whimsicalLabel)
        button.slotID = slot
        wireButton(button) { [weak self] in self?.refreshCaption(for: slot) }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = "⌘-click to bind macro"
        return button
    }

    private func wireButton(
        _ button: ClickerPaletteButton,
        hover: @escaping () -> Void,
        click: (() -> Void)? = nil
    ) {
        button.onHover = { [weak self] entered in
            if entered {
                hover()
            } else {
                self?.refreshCaption(for: nil)
            }
        }
        button.onClick = { [weak self] in
            guard let self else { return }
            if NSApp.currentEvent?.modifierFlags.contains(.command) == true {
                if let slot = button.slotID {
                    bindSlot(slot)
                }
                return
            }
            if let customClick = click {
                customClick()
                return
            }
            guard let slot = button.slotID else { return }
            let macroName = AppContext.shared.prefs.clickerMan.slot(for: slot).macroName
            MacroClicker.sendMacro(named: macroName)
        }
    }

    private func wireButton(_ button: ClickerPaletteButton, hover: @escaping () -> Void) {
        wireButton(button, hover: hover, click: nil)
    }

    private func bindSlot(_ slot: ClickerSlotID) {
        let macros = AppContext.shared.universalReactionsStore.state?.macroList.items ?? []
        let alert = NSAlert()
        alert.messageText = "Bind \(slotTitle(slot)) to macro"
        alert.informativeText = "Choose a universal macro for this clicker button."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 220, height: 26), pullsDown: false)
        popup.addItem(withTitle: "(none)")
        for macro in macros {
            popup.addItem(withTitle: macro.name)
        }

        let currentName = AppContext.shared.prefs.clickerMan.slot(for: slot).macroName
        if currentName.isEmpty {
            popup.selectItem(at: 0)
        } else if let index = popup.itemArray.firstIndex(where: { $0.title == currentName }) {
            popup.selectItem(at: index)
        }

        alert.accessoryView = popup
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let selected = popup.indexOfSelectedItem == 0 ? "" : popup.titleOfSelectedItem ?? ""
        AppContext.shared.prefs.clickerMan.setMacroName(selected, for: slot)
        AppContext.shared.save()
        refreshCaption(for: slot)
    }

    private func slotTitle(_ slot: ClickerSlotID) -> String {
        if slot.isGrid {
            return "button \(slot.whimsicalLabel)"
        }
        return "direction button"
    }
}

private final class ClickerRootView: NSView {
    override var isFlipped: Bool { true }
    override var isOpaque: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        ClickerAppearance.panelGray.setFill()
        bounds.fill()
    }
}

private final class ClickerCompassPanel: NSView {
    struct Placement {
        let slot: ClickerSlotID
        let frame: NSRect
    }

    private var placements: [Placement] = []
    private var hoveredSlot: ClickerSlotID?
    var onHoverSlot: ((ClickerSlotID?) -> Void)?

    override var isFlipped: Bool { true }
    override var isOpaque: Bool { true }

    func configure(placements: [Placement]) {
        self.placements = placements
    }

    override func draw(_ dirtyRect: NSRect) {
        ClickerAppearance.panelGray.setFill()
        bounds.fill()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }

    override func mouseMoved(with event: NSEvent) {
        updateHover(at: convert(event.locationInWindow, from: nil))
    }

    override func mouseEntered(with event: NSEvent) {
        updateHover(at: convert(event.locationInWindow, from: nil))
    }

    override func mouseExited(with event: NSEvent) {
        setHoveredSlot(nil)
    }

    private func updateHover(at point: NSPoint) {
        setHoveredSlot(directionSlot(at: point))
    }

    private func setHoveredSlot(_ slot: ClickerSlotID?) {
        guard slot != hoveredSlot else { return }
        hoveredSlot = slot
        onHoverSlot?(slot)
    }

    private func directionSlot(at point: NSPoint) -> ClickerSlotID? {
        for placement in placements {
            guard placement.frame.contains(point) else { continue }
            let localPoint = NSPoint(
                x: point.x - placement.frame.minX,
                y: point.y - placement.frame.minY
            )
            let localRect = NSRect(origin: .zero, size: placement.frame.size)
            if ClickerAppearance.directionWedgeContains(localPoint, in: localRect, slot: placement.slot) {
                return placement.slot
            }
        }
        return nil
    }
}

private final class ClickerGridPanel: NSView {
    let columns: Int
    let rows: Int

    override var isFlipped: Bool { true }

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isOpaque: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        ClickerAppearance.drawGridPanel(in: bounds, columns: columns, rows: rows)
    }
}

// MARK: - Controls

private enum ClickerPaletteButtonStyle {
    case direction(ClickerSlotID)
    case vertical(up: Bool)
    case grid(label: String)
}

private final class ClickerPaletteButton: NSView {
    var style: ClickerPaletteButtonStyle = .direction(.north)
    var slotID: ClickerSlotID?
    var onHover: ((Bool) -> Void)?
    var onClick: (() -> Void)?

    private var isHighlighted = false

    override var isFlipped: Bool { true }

    override var isOpaque: Bool {
        switch style {
        case .direction, .grid: return false
        case .vertical: return true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }
        if case let .direction(slot) = style {
            guard ClickerAppearance.directionWedgeContains(point, in: bounds, slot: slot) else {
                return nil
            }
        }
        return self
    }

    override func mouseDown(with event: NSEvent) {
        isHighlighted = true
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let inside: Bool
        if case let .direction(slot) = style {
            inside = ClickerAppearance.directionWedgeContains(point, in: bounds, slot: slot)
        } else {
            inside = bounds.contains(point)
        }
        isHighlighted = false
        needsDisplay = true
        if inside {
            onClick?()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        switch style {
        case let .direction(slot):
            ClickerAppearance.drawDirectionArrow(in: bounds, slot: slot, pressed: isHighlighted)
        case let .vertical(up):
            ClickerAppearance.drawVerticalArrow(in: bounds, up: up, pressed: isHighlighted)
        case let .grid(label):
            ClickerAppearance.drawGridCell(in: bounds, label: label, pressed: isHighlighted)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        if case .direction = style {
            return
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }

    override func mouseEntered(with event: NSEvent) {
        onHover?(true)
    }

    override func mouseExited(with event: NSEvent) {
        onHover?(false)
    }
}
