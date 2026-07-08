//
//  AboutWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Custom About box inspired by Savitar 1's scrolling-credits dialog.
final class AboutWindowController: NSWindowController, NSWindowDelegate {
    static let shared = AboutWindowController()

    private let content = AboutView()
    private var hasCentered = false

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: AboutView.contentWidth, height: AboutView.contentHeight),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About Savitar"
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        window.contentView = content
        window.fitContentSize(
            NSSize(width: AboutView.contentWidth, height: AboutView.contentHeight),
            centerIfNeeded: false
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showAbout() {
        showWindow(nil)
        if !hasCentered {
            window?.center()
            hasCentered = true
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        content.restartCredits()
    }

    func windowWillClose(_: Notification) {
        content.stopCredits()
    }

    override func cancelOperation(_: Any?) {
        window?.close()
    }
}

// MARK: - Content

private final class AboutView: NSView {
    static let contentWidth: CGFloat = 320
    static let contentHeight: CGFloat = 460

    /// Warm taupe from Savitar 1 About dialog (`RGBColor {0xCCCC, 0x9999, 0x6666}`).
    static let backdrop = NSColor(srgbRed: 0.80, green: 0.60, blue: 0.40, alpha: 1)

    private let medallionView = NSImageView()
    private let creditsView = ScrollingCreditsView()
    private let versionLabel = NSTextField(labelWithString: "")
    private let bylineLabel = NSTextField(labelWithString: "By Jay Koutavas")
    private let copyrightLabel = NSTextField(labelWithString: "")
    private let linkButton = NSButton(title: "https://www.heynow.com/savitar", target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = Self.backdrop.cgColor

        configureMedallion()
        configureLabels()
        configureCredits()
        layoutSubtree()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func restartCredits() {
        creditsView.restart()
    }

    func stopCredits() {
        creditsView.stop()
    }

    override func mouseDown(with _: NSEvent) {
        window?.close()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Pass clicks on the website link through; everything else dismisses the About box.
        let local = convert(point, from: superview)
        if linkButton.frame.contains(local) {
            return linkButton
        }
        return bounds.contains(local) ? self : nil
    }

    private func configureMedallion() {
        medallionView.image = NSImage(named: "AboutMedallion")
        medallionView.imageScaling = .scaleProportionallyUpOrDown
        medallionView.imageAlignment = .alignCenter
        addSubview(medallionView)
    }

    private func configureCredits() {
        addSubview(creditsView)
    }

    private func configureLabels() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        versionLabel.stringValue = "Version \(version) (\(build))"
        versionLabel.alignment = .center
        versionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        versionLabel.textColor = NSColor(srgbRed: 0.18, green: 0.12, blue: 0.08, alpha: 1)

        bylineLabel.alignment = .center
        bylineLabel.font = .systemFont(ofSize: 12)
        bylineLabel.textColor = NSColor(srgbRed: 0.18, green: 0.12, blue: 0.08, alpha: 1)

        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
            ?? "Copyright © 1996-2026 Heynow Software. All rights reserved."
        copyrightLabel.stringValue = copyright
        copyrightLabel.alignment = .center
        copyrightLabel.font = .systemFont(ofSize: 10)
        copyrightLabel.textColor = NSColor(srgbRed: 0.25, green: 0.16, blue: 0.10, alpha: 1)
        copyrightLabel.maximumNumberOfLines = 2
        copyrightLabel.lineBreakMode = .byWordWrapping

        linkButton.bezelStyle = .inline
        linkButton.isBordered = false
        linkButton.font = .systemFont(ofSize: 11)
        linkButton.contentTintColor = NSColor(srgbRed: 0.20, green: 0.28, blue: 0.55, alpha: 1)
        linkButton.target = self
        linkButton.action = #selector(openWebsite(_:))

        for view in [versionLabel, bylineLabel, copyrightLabel, linkButton] as [NSView] {
            addSubview(view)
        }
    }

    private func layoutSubtree() {
        let width = Self.contentWidth
        let labelWidth = width - 32

        // Top: medallion (no credits overlay).
        let medallionTop: CGFloat = 10
        let medallionHeight: CGFloat = 230
        let medallionWidth: CGFloat = 210
        medallionView.frame = NSRect(
            x: (width - medallionWidth) / 2,
            y: Self.contentHeight - medallionTop - medallionHeight,
            width: medallionWidth,
            height: medallionHeight
        )

        // Middle: version / byline / copyright.
        var y = medallionView.frame.minY - 10
        versionLabel.frame = NSRect(x: 16, y: y - 16, width: labelWidth, height: 16)
        y = versionLabel.frame.minY - 4
        bylineLabel.frame = NSRect(x: 16, y: y - 16, width: labelWidth, height: 16)
        y = bylineLabel.frame.minY - 4
        copyrightLabel.frame = NSRect(x: 16, y: y - 28, width: labelWidth, height: 28)

        // Bottom: credits scroller, then website link.
        let linkHeight: CGFloat = 18
        let linkBottom: CGFloat = 10
        linkButton.frame = NSRect(x: 16, y: linkBottom, width: labelWidth, height: linkHeight)

        let creditsBottom = linkButton.frame.maxY + 8
        let creditsTop = copyrightLabel.frame.minY - 8
        let creditsHeight = max(80, creditsTop - creditsBottom)
        let creditsWidth: CGFloat = 260
        creditsView.frame = NSRect(
            x: (width - creditsWidth) / 2,
            y: creditsBottom,
            width: creditsWidth,
            height: creditsHeight
        )
    }

    @objc private func openWebsite(_: Any?) {
        guard let url = URL(string: "https://www.heynow.com/savitar") else { return }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Credits copy

private enum AboutCredits {
    static let heynowTitle = "Special Heynows to:"
    static let savitar2Title = "And for Savitar 2:"

    private static let center: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.paragraphSpacing = 6
        return style
    }()

    private static let bodyColor = NSColor(srgbRed: 0.22, green: 0.14, blue: 0.09, alpha: 1)

    private static var bodyAttributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: bodyColor,
            .paragraphStyle: center,
        ]
    }

    static var heynowBody: NSAttributedString {
        let names = [
            "Rich Connamacher",
            "John \"Hsoi\" Daubs",
            "Dee",
            "Ferret",
            "Jackie \"Kira\" Hamilton",
            "Matthew Jean",
            "C.S. Mo",
            "James \"Dadditude\" Naron",
            "Chris \"Psion\" Williams",
            "Joshua \"Rozzin\" Rosen",
            "Nick Walker",
            "Russell \"dood\" Zornes",
            "23 (fnord)",
        ]
        return NSAttributedString(string: names.joined(separator: "\n\n") + "\n\n", attributes: bodyAttributes)
    }

    static var packagesBody: NSAttributedString {
        let modern = [
            "ReSwift",
            "SwiftyXMLParser",
            "swift-log",
            "Sparkle",
            "TelemetryDeck",
        ]
        return NSAttributedString(string: modern.joined(separator: "\n\n") + "\n\n", attributes: bodyAttributes)
    }

    static var mirthBody: NSAttributedString {
        NSAttributedString(string: "Made with mirth\nin New Hampshire", attributes: bodyAttributes)
    }
}

// MARK: - Scrolling pane

private final class ScrollingCreditsView: NSView {
    private let stickyTitle = NSTextField(labelWithString: "")
    private let bodyView = CreditsBodyView()

    private var heynowHeight: CGFloat = 0
    private var packagesHeight: CGFloat = 0
    private var mirthHeight: CGFloat = 0
    private var sectionGap: CGFloat = 0
    private var totalHeight: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var timer: Timer?
    private var delayRemaining: CFTimeInterval = 3
    private var fadeInProgress: CGFloat = 0
    private var didPauseForSavitar2 = false
    private var didClearStickyForMirth = false
    private var didPauseForMirth = false
    private let pixelsPerSecond: CGFloat = 18
    private let stickyHeight: CGFloat = 22
    private let sectionPauseSeconds: CFTimeInterval = 1.25
    private let mirthHoldSeconds: CFTimeInterval = 4.5

    /// Scroll position where Heynow names have cleared and the viewport is empty (in the gap).
    private var heynowClearedOffset: CGFloat {
        heynowHeight + bodyView.bounds.height
    }

    /// Scroll position where packages have cleared; mirth is about to enter.
    private var packagesClearedOffset: CGFloat {
        heynowHeight + sectionGap + packagesHeight + bodyView.bounds.height
    }

    /// Scroll position where the mirth closer sits centered alone in the body.
    private var mirthHoldOffset: CGFloat {
        totalHeight + (bodyView.bounds.height - mirthHeight) / 2
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = AboutView.backdrop.cgColor

        stickyTitle.alignment = .center
        stickyTitle.font = .boldSystemFont(ofSize: 11)
        stickyTitle.textColor = NSColor(srgbRed: 0.18, green: 0.12, blue: 0.08, alpha: 1)
        stickyTitle.backgroundColor = AboutView.backdrop
        stickyTitle.drawsBackground = true
        stickyTitle.stringValue = AboutCredits.heynowTitle
        addSubview(stickyTitle)

        bodyView.wantsLayer = true
        addSubview(bodyView)
        rebuildBodies()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stop()
    }

    override func layout() {
        super.layout()
        let width = bounds.width
        stickyTitle.frame = NSRect(x: 0, y: bounds.height - stickyHeight, width: width, height: stickyHeight)
        bodyView.frame = NSRect(x: 0, y: 0, width: width, height: max(0, bounds.height - stickyHeight))
        bodyView.updateFadeMask()
        rebuildBodies()
        bodyView.scrollOffset = scrollOffset
    }

    func restart() {
        stop()
        scrollOffset = 0
        delayRemaining = 3
        fadeInProgress = 0
        didPauseForSavitar2 = false
        didClearStickyForMirth = false
        didPauseForMirth = false
        alphaValue = 0
        stickyTitle.stringValue = AboutCredits.heynowTitle
        stickyTitle.isHidden = false
        bodyView.scrollOffset = 0
        bodyView.needsDisplay = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func rebuildBodies() {
        let drawWidth = max(1, bounds.width - 8)
        let measureSize = NSSize(width: drawWidth, height: .greatestFiniteMagnitude)
        let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        heynowHeight = ceil(AboutCredits.heynowBody.boundingRect(with: measureSize, options: options).height)
        packagesHeight = ceil(AboutCredits.packagesBody.boundingRect(with: measureSize, options: options).height)
        mirthHeight = ceil(AboutCredits.mirthBody.boundingRect(with: measureSize, options: options).height)
        // Full-viewport gaps: after Heynows (sticky handoff) and before mirth (solo closer).
        sectionGap = max(bodyView.bounds.height, 1)
        totalHeight = heynowHeight + sectionGap + packagesHeight + sectionGap + mirthHeight

        bodyView.heynowBody = AboutCredits.heynowBody
        bodyView.packagesBody = AboutCredits.packagesBody
        bodyView.mirthBody = AboutCredits.mirthBody
        bodyView.heynowHeight = heynowHeight
        bodyView.packagesHeight = packagesHeight
        bodyView.mirthHeight = mirthHeight
        bodyView.sectionGap = sectionGap
        bodyView.totalHeight = totalHeight
    }

    private func beginLoopRestart() {
        scrollOffset = 0
        delayRemaining = 1.5
        fadeInProgress = 0
        didPauseForSavitar2 = false
        didClearStickyForMirth = false
        didPauseForMirth = false
        alphaValue = 0
        stickyTitle.stringValue = AboutCredits.heynowTitle
        stickyTitle.isHidden = false
        bodyView.scrollOffset = 0
        bodyView.needsDisplay = true
    }

    private func tick() {
        let dt = 1.0 / 30.0

        if delayRemaining > 0 {
            delayRemaining -= dt
            if delayRemaining <= 0, didPauseForMirth {
                // Mirth hold finished — restart the roll.
                beginLoopRestart()
            }
            return
        }

        if fadeInProgress < 1 {
            fadeInProgress = min(1, fadeInProgress + CGFloat(dt / 0.75))
            alphaValue = fadeInProgress
        }

        scrollOffset += pixelsPerSecond * CGFloat(dt)

        // After Heynows clear, snap to the gap, flip sticky first, then pause before Savitar 2.
        if !didPauseForSavitar2, scrollOffset >= heynowClearedOffset {
            didPauseForSavitar2 = true
            scrollOffset = heynowClearedOffset
            stickyTitle.stringValue = AboutCredits.savitar2Title
            stickyTitle.isHidden = false
            delayRemaining = sectionPauseSeconds
            bodyView.scrollOffset = scrollOffset
            bodyView.needsDisplay = true
            return
        }

        // After packages clear, drop the sticky before mirth enters.
        if didPauseForSavitar2, !didClearStickyForMirth, scrollOffset >= packagesClearedOffset {
            didClearStickyForMirth = true
            scrollOffset = packagesClearedOffset
            stickyTitle.stringValue = ""
            stickyTitle.isHidden = true
            delayRemaining = sectionPauseSeconds
            bodyView.scrollOffset = scrollOffset
            bodyView.needsDisplay = true
            return
        }

        // Park on the mirth closer (sticky already clear), hold, then loop.
        if didClearStickyForMirth, !didPauseForMirth, scrollOffset >= mirthHoldOffset {
            didPauseForMirth = true
            scrollOffset = mirthHoldOffset
            delayRemaining = mirthHoldSeconds
            bodyView.scrollOffset = scrollOffset
            bodyView.needsDisplay = true
            return
        }

        bodyView.scrollOffset = scrollOffset
        bodyView.needsDisplay = true
    }
}

private final class CreditsBodyView: NSView {
    var heynowBody = NSAttributedString()
    var packagesBody = NSAttributedString()
    var mirthBody = NSAttributedString()
    var heynowHeight: CGFloat = 0
    var packagesHeight: CGFloat = 0
    var mirthHeight: CGFloat = 0
    var sectionGap: CGFloat = 0
    var totalHeight: CGFloat = 0
    var scrollOffset: CGFloat = 0

    private let fadeMask = CAGradientLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        // Fade only the bottom edge so sticky title stays crisp.
        fadeMask.colors = [
            NSColor.clear.cgColor,
            NSColor.black.cgColor,
            NSColor.black.cgColor,
        ]
        fadeMask.locations = [0, 0.18, 1]
        fadeMask.startPoint = CGPoint(x: 0.5, y: 0)
        fadeMask.endPoint = CGPoint(x: 0.5, y: 1)
        layer?.mask = fadeMask
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateFadeMask() {
        fadeMask.frame = bounds
    }

    override func draw(_: NSRect) {
        guard !heynowBody.string.isEmpty else { return }

        let padding: CGFloat = 4
        let drawWidth = max(1, bounds.width - padding * 2)
        let stripBottom = -totalHeight + scrollOffset

        // Top of strip → bottom: Heynow names, gap, packages, gap, mirth closer.
        let heynowRect = NSRect(
            x: padding,
            y: stripBottom + mirthHeight + sectionGap + packagesHeight + sectionGap,
            width: drawWidth,
            height: heynowHeight
        )
        heynowBody.draw(with: heynowRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let packagesRect = NSRect(
            x: padding,
            y: stripBottom + mirthHeight + sectionGap,
            width: drawWidth,
            height: packagesHeight
        )
        packagesBody.draw(with: packagesRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let mirthRect = NSRect(
            x: padding,
            y: stripBottom,
            width: drawWidth,
            height: mirthHeight
        )
        mirthBody.draw(with: mirthRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }
}
