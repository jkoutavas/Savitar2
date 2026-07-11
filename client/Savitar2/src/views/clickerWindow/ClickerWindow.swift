//
//  ClickerWindow.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Macro Clicker palette — floats above sessions without stealing key focus (v1 behavior).
final class ClickerWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func setContentSize(_ size: NSSize) {
        super.setContentSize(ClickerContentViewController.designedContentSize)
    }

    override func setFrame(_ frameRect: NSRect, display displayFlag: Bool) {
        let designed = ClickerContentViewController.designedContentSize
        var contentRect = contentRect(forFrameRect: frameRect)
        contentRect.size = designed
        var frame = self.frameRect(forContentRect: contentRect)
        frame.origin = frameRect.origin
        super.setFrame(frame, display: displayFlag)
    }
}
