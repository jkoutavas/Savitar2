//
//  NSWindow+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }

    /// Applies standard macOS Settings window chrome (modeless, close-only, non-resizable).
    func configureAsSettingsWindow(delegate: NSWindowDelegate?) {
        styleMask = [.titled, .closable]
        self.delegate = delegate
        isReleasedWhenClosed = false
    }

    /// Whether AppKit has a saved frame for `windowFrameAutosaveName` / `setFrameAutosaveName`.
    static func hasAutosavedFrame(named autosaveName: String) -> Bool {
        UserDefaults.standard.object(forKey: "NSWindow Frame \(autosaveName)") != nil
    }

    /// Sizes the window to a content area and optionally centers on first display.
    func fitContentSize(_ contentSize: NSSize, centerIfNeeded: Bool) {
        setContentSize(contentSize)
        contentMinSize = contentSize
        contentMaxSize = contentSize
        if centerIfNeeded {
            center()
        }
    }

    /// Resize content while keeping the title bar in place (Settings HIG pane changes).
    func setContentSizeKeepingTitleBar(_ contentSize: NSSize, animate: Bool) {
        let contentRect = contentRect(forFrameRect: frame)
        let chromeWidth = frame.width - contentRect.width
        let chromeHeight = frame.height - contentRect.height
        var newFrame = frame
        newFrame.size = NSSize(
            width: contentSize.width + chromeWidth,
            height: contentSize.height + chromeHeight
        )
        newFrame.origin.y = frame.maxY - newFrame.height
        setFrame(newFrame, display: true, animate: animate)
    }

    /// Centers this window over `parent` (child modal dialogs).
    func centerRelative(to parent: NSWindow) {
        let parentFrame = parent.frame
        var frame = self.frame
        frame.origin.x = parentFrame.midX - frame.width / 2
        frame.origin.y = parentFrame.midY - frame.height / 2
        setFrame(frame, display: true)
    }
}
