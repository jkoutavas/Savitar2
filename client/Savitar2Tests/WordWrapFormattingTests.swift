//
//  WordWrapFormattingTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

class WordWrapFormattingTests: XCTestCase {
    func testOutputPreCSSEnabledIncludesPreWrap() {
        let css = WordWrapFormatting.outputPreCSS(wordWrapEnabled: true)
        XCTAssertTrue(css.contains("pre-wrap"))
        XCTAssertTrue(css.contains("display: block"))
        XCTAssertTrue(css.contains("overflow-wrap: anywhere"))
    }

    func testOutputPreCSSDisabledPreservesLineLength() {
        let css = WordWrapFormatting.outputPreCSS(wordWrapEnabled: false)
        XCTAssertTrue(css.contains("white-space: pre;"))
        XCTAssertFalse(css.contains("pre-wrap"))
    }

    func testApplyWordWrapToTextView() {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 200, height: 80))
        let textView = NSTextView(frame: scrollView.contentView.bounds)
        scrollView.documentView = textView

        WordWrapFormatting.apply(to: textView, enabled: true)
        XCTAssertFalse(scrollView.hasHorizontalScroller)
        XCTAssertTrue(textView.textContainer?.widthTracksTextView ?? false)
        XCTAssertEqual(textView.textContainer?.lineBreakMode, .byCharWrapping)
        XCTAssertEqual(textView.textContainer?.containerSize.width ?? 0, 200, accuracy: 0.5)

        WordWrapFormatting.apply(to: textView, enabled: false)
        XCTAssertTrue(scrollView.hasHorizontalScroller)
        XCTAssertFalse(textView.textContainer?.widthTracksTextView ?? true)
        XCTAssertEqual(textView.autoresizingMask, [])
    }

    func testDisabledWordWrapKeepsLongLineOnOneRow() {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 200, height: 80))
        let textView = NSTextView(frame: scrollView.contentView.bounds)
        scrollView.documentView = textView
        textView.string = String(repeating: "a", count: 400)
        textView.font = NSFont.userFixedPitchFont(ofSize: 12) ?? NSFont.systemFont(ofSize: 12)

        WordWrapFormatting.apply(to: textView, enabled: false)

        guard let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            XCTFail("Missing text layout objects")
            return
        }

        layoutManager.ensureLayout(for: textContainer)
        var lineCount = 0
        layoutManager.enumerateLineFragments(forGlyphRange: layoutManager.glyphRange(for: textContainer)) { _, _, _, _, _ in
            lineCount += 1
        }

        XCTAssertEqual(lineCount, 1)
        XCTAssertGreaterThan(textView.frame.width, scrollView.contentView.bounds.width)
    }
}
