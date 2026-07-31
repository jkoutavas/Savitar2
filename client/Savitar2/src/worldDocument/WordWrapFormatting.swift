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
            body { overflow-x: hidden; }
            .reset.bg-reset {
                max-width: 100%;
            }
            pre, code {
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
            let minimumSize = minimumDocumentSize(for: textView, in: scrollView)

            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            // Override storyboard maxSize.width (600), which lets the text view outgrow the pane.
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = minimumSize

            textContainer.widthTracksTextView = true
            textContainer.lineBreakMode = .byCharWrapping
            textContainer.containerSize = NSSize(width: wrapWidth, height: CGFloat.greatestFiniteMagnitude)

            if let layoutManager = textView.layoutManager {
                layoutManager.ensureLayout(for: textContainer)
            }
            synchronizeVisibleDocumentHeight(of: textView, in: scrollView)
        } else {
            textView.isHorizontallyResizable = true
            // Do not pin width to the scroll view; that forces soft line breaks.
            textView.autoresizingMask = []
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = minimumDocumentSize(for: textView, in: scrollView)

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
        let clipHeight = scrollView?.contentView.bounds.height ?? textView.bounds.height
        var frame = textView.frame
        let targetWidth = max(usedWidth, clipWidth)
        let targetHeight = max(frame.size.height, clipHeight)

        guard abs(frame.size.width - targetWidth) > 0.5
            || abs(frame.size.height - targetHeight) > 0.5 else { return }
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        textView.setFrameSize(frame.size)
    }

    private static func minimumDocumentSize(for textView: NSTextView, in scrollView: NSScrollView) -> NSSize {
        NSSize(
            width: min(textView.frame.width, scrollView.contentView.bounds.width),
            height: scrollView.contentView.bounds.height
        )
    }

    private static func synchronizeVisibleDocumentHeight(of textView: NSTextView, in scrollView: NSScrollView) {
        let targetHeight = scrollView.contentView.bounds.height
        guard textView.frame.height < targetHeight else { return }

        var frame = textView.frame
        frame.size.height = targetHeight
        textView.setFrameSize(frame.size)
    }
}
