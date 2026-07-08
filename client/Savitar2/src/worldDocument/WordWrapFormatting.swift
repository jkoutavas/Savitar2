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
            pre {
                overflow-x: auto;
                white-space: pre-wrap;
                white-space: -moz-pre-wrap;
                white-space: -pre-wrap;
                white-space: -o-pre-wrap;
                word-wrap: break-word;
                display: inline;
                margin: 0;
            }
            """
        }
        return """
        pre {
            overflow-x: visible;
            white-space: pre;
            display: inline;
            margin: 0;
        }
        body { overflow-x: auto; }
        """
    }

    static func apply(to textView: NSTextView, enabled: Bool) {
        guard let scrollView = textView.enclosingScrollView,
              let textContainer = textView.textContainer else { return }

        scrollView.hasHorizontalScroller = !enabled

        if enabled {
            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            textContainer.widthTracksTextView = true
            textContainer.containerSize = NSSize(
                width: scrollView.contentSize.width,
                height: CGFloat.greatestFiniteMagnitude
            )
        } else {
            textView.isHorizontallyResizable = true
            textView.autoresizingMask = [.width, .height]
            textContainer.widthTracksTextView = false
            textContainer.containerSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        }
        textView.needsLayout = true
    }
}
