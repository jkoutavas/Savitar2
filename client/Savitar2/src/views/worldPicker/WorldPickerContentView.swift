//
//  WorldPickerContentView.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Programmatic layout for the World Picker — welcome header, world list, and connect chrome.
final class WorldPickerContentView: NSView {
    static let contentWidth: CGFloat = 520
    static let rowHeight: CGFloat = 44
    static let minVisibleRows = 6
    static let maxVisibleRows = 10

    let tableView = NSTableView()
    let addButton = NSButton(title: "Add…", target: nil, action: nil)
    let removeButton = NSButton(title: "Remove", target: nil, action: nil)
    let connectButton = NSButton(title: "Connect", target: nil, action: nil)

    private let headerIcon = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Choose a World")
    private let subtitleLabel = NSTextField(
        labelWithString: "Double-click a world to connect, or select one and press Connect."
    )
    private let detailCard = NSView()
    private let detailIcon = NSImageView()
    private let detailLabel = NSTextField(labelWithString: "Select a world to see its address.")
    private let tableScrollView = NSScrollView()
    private let headerSeparator = NSBox()
    private var tableHeightConstraint: NSLayoutConstraint?

    override var wantsUpdateLayer: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureChrome()
        installSubviews()
        activateConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTableHeight(rowCount: Int) {
        let visibleRows = min(max(rowCount, Self.minVisibleRows), Self.maxVisibleRows)
        tableHeightConstraint?.constant = CGFloat(visibleRows) * Self.rowHeight + 6
    }

    func updateDetail(for world: World?) {
        if let world, !world.host.isEmpty {
            detailLabel.stringValue = world.telnetString
            detailLabel.textColor = .labelColor
            connectButton.isEnabled = true
            removeButton.isEnabled = true
        } else {
            detailLabel.stringValue = "Select a world to see its address."
            detailLabel.textColor = .secondaryLabelColor
            connectButton.isEnabled = false
            removeButton.isEnabled = false
        }
    }

    func fittingHeight(rowCount: Int) -> CGFloat {
        let visibleRows = min(max(rowCount, Self.minVisibleRows), Self.maxVisibleRows)
        let tableHeight = CGFloat(visibleRows) * Self.rowHeight + 6
        // Header + separator + table + detail + footer + vertical padding.
        return 76 + 1 + tableHeight + 12 + 52 + 12 + 44 + 24
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        refreshAppearanceDependentColors()
    }

    override func updateLayer() {
        super.updateLayer()
        refreshAppearanceDependentColors()
    }

    private func configureChrome() {
        wantsLayer = true

        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .labelColor

        subtitleLabel.font = NSFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.maximumNumberOfLines = 2
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if #available(macOS 11.0, *) {
            headerIcon.image = NSImage(
                systemSymbolName: "globe.americas.fill",
                accessibilityDescription: "Worlds"
            )
            headerIcon.contentTintColor = .controlAccentColor
            detailIcon.image = NSImage(
                systemSymbolName: "antenna.radiowaves.left.and.right",
                accessibilityDescription: "Connection"
            )
            detailIcon.contentTintColor = .secondaryLabelColor
            tableView.style = .inset
        }

        detailCard.wantsLayer = true
        detailCard.layer?.cornerRadius = 8
        detailCard.layer?.borderWidth = 1
        refreshAppearanceDependentColors()

        detailLabel.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)
            ?? NSFont.monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        detailLabel.lineBreakMode = .byTruncatingMiddle

        tableView.headerView = nil
        tableView.rowHeight = Self.rowHeight
        tableView.intercellSpacing = NSSize(width: 0, height: 4)
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.backgroundColor = .clear
        tableView.gridStyleMask = []
        tableView.focusRingType = .none
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("World"))
        column.width = Self.contentWidth - 48
        tableView.addTableColumn(column)

        tableScrollView.documentView = tableView
        tableScrollView.hasVerticalScroller = true
        tableScrollView.autohidesScrollers = true
        tableScrollView.drawsBackground = false
        tableScrollView.borderType = .noBorder

        addButton.bezelStyle = .rounded
        addButton.toolTip = "Add a new world"

        removeButton.bezelStyle = .rounded
        removeButton.isEnabled = false
        removeButton.toolTip = "Remove the selected world"

        connectButton.bezelStyle = .rounded
        connectButton.keyEquivalent = "\r"
        connectButton.isEnabled = false
        connectButton.toolTip = "Open a session to the selected world"
        if #available(macOS 11.0, *) {
            connectButton.contentTintColor = .controlAccentColor
        }
        connectButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
    }

    /// Layer-backed fills must be re-resolved when the system appearance changes (e.g. Auto dark → light).
    func refreshAppearanceDependentColors() {
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        detailCard.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.55).cgColor
        detailCard.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }

    private func installSubviews() {
        headerSeparator.boxType = .separator

        for item in [
            headerIcon, titleLabel, subtitleLabel, headerSeparator,
            tableScrollView, detailCard, detailIcon, detailLabel,
            addButton, removeButton, connectButton
        ] {
            item.translatesAutoresizingMaskIntoConstraints = false
            addSubview(item)
        }

        detailCard.addSubview(detailIcon)
        detailCard.addSubview(detailLabel)
    }

    private func activateConstraints() {
        let padding: CGFloat = 20
        tableHeightConstraint = tableScrollView.heightAnchor.constraint(equalToConstant: Self.rowHeight * 6 + 6)
        tableHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            headerIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headerIcon.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            headerIcon.widthAnchor.constraint(equalToConstant: 32),
            headerIcon.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: headerIcon.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            headerSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headerSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            headerSeparator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            headerSeparator.heightAnchor.constraint(equalToConstant: 1),

            tableScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            tableScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            tableScrollView.topAnchor.constraint(equalTo: headerSeparator.bottomAnchor, constant: 12),

            detailCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            detailCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            detailCard.topAnchor.constraint(equalTo: tableScrollView.bottomAnchor, constant: 12),
            detailCard.heightAnchor.constraint(equalToConstant: 52),

            detailIcon.leadingAnchor.constraint(equalTo: detailCard.leadingAnchor, constant: 12),
            detailIcon.centerYAnchor.constraint(equalTo: detailCard.centerYAnchor),
            detailIcon.widthAnchor.constraint(equalToConstant: 18),
            detailIcon.heightAnchor.constraint(equalToConstant: 18),

            detailLabel.leadingAnchor.constraint(equalTo: detailIcon.trailingAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(equalTo: detailCard.trailingAnchor, constant: -12),
            detailLabel.centerYAnchor.constraint(equalTo: detailCard.centerYAnchor),

            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding - 2),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            removeButton.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 8),
            removeButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),

            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding + 2),
            connectButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            connectButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 108)
        ])
    }
}

// MARK: - Row cell

final class WorldPickerRowCell: NSTableCellView {
    static let reuseID = NSUserInterfaceItemIdentifier("WorldPickerRow")

    private let nameLabel = NSTextField(labelWithString: "")
    private let hostLabel = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        installLabels()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: WorldViewModel) {
        nameLabel.stringValue = viewModel.title
        hostLabel.stringValue = viewModel.hostSummary
    }

    private func installLabels() {
        nameLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor = .labelColor
        hostLabel.font = NSFont.userFixedPitchFont(ofSize: 11)
            ?? NSFont.systemFont(ofSize: 11)
        hostLabel.textColor = .secondaryLabelColor

        for label in [nameLabel, hostLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.lineBreakMode = .byTruncatingTail
            addSubview(label)
        }

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),

            hostLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            hostLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            hostLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1)
        ])
    }
}
