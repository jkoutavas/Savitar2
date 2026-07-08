//
//  WordWrapFormatting.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

enum WordWrapFormatting {
    /// CSS for session output `<pre>` blocks (WKWebView).
    static func outputPreCSS(wordWrapEnabled: Bool) -> String {
        if wordWrapEnabled {
            return """
            .reset.bg-reset {
                max-width: 100%;
            }
            pre {
                display: block;
                white-space: pre-wrap;
                overflow-wrap: anywhere;
                word-wrap: break-word;
                max-width: 100%;
                margin: 0;
                overflow-x: hidden;
            }
            """
        }
        return """
        pre {
            display: block;
            white-space: pre;
            margin: 0;
        }
        body { overflow-x: auto; }
        """
    }

    static func apply(to textView: NSTextView, enabled: Bool) {
        guard let scrollView = textView.enclosingScrollView,
              let textContainer = textView.textContainer else { return }

        scrollView.hasHorizontalScroller = !enabled
        textView.isVerticallyResizable = true

        if enabled {
            let wrapWidth = max(scrollView.contentSize.width, scrollView.contentView.bounds.width, 1)

            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            // Override storyboard maxSize.width (600), which lets the text view outgrow the pane.
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = NSSize(width: 0, height: 0)

            textContainer.widthTracksTextView = true
            textContainer.lineBreakMode = .byCharWrapping
            textContainer.containerSize = NSSize(width: wrapWidth, height: CGFloat.greatestFiniteMagnitude)

            if let layoutManager = textView.layoutManager {
                layoutManager.ensureLayout(for: textContainer)
            }
        } else {
            textView.isHorizontallyResizable = true
            // Do not pin width to the scroll view; that forces soft line breaks.
            textView.autoresizingMask = []
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = NSSize(width: 0, height: 0)

            textContainer.widthTracksTextView = false
            textContainer.lineBreakMode = .byWordWrapping
            textContainer.containerSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )

            synchronizeHorizontalSize(of: textView, in: scrollView)
        }
        textView.needsLayout = true
    }

    /// Grow the text view frame so long unbroken lines scroll horizontally instead of wrapping.
    static func synchronizeHorizontalSize(of textView: NSTextView, in scrollView: NSScrollView? = nil) {
        let scrollView = scrollView ?? textView.enclosingScrollView
        guard let textContainer = textView.textContainer,
              let layoutManager = textView.layoutManager else { return }

        layoutManager.ensureLayout(for: textContainer)
        let usedWidth = ceil(layoutManager.usedRect(for: textContainer).width)
        let clipWidth = scrollView?.contentView.bounds.width ?? textView.bounds.width
        let targetWidth = max(usedWidth, clipWidth)

        var frame = textView.frame
        guard abs(frame.size.width - targetWidth) > 0.5 else { return }
        frame.size.width = targetWidth
        textView.setFrameSize(frame.size)
    }
}
