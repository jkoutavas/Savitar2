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
        XCTAssertTrue(css.contains("word-wrap: break-word"))
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

        WordWrapFormatting.apply(to: textView, enabled: false)
        XCTAssertTrue(scrollView.hasHorizontalScroller)
        XCTAssertFalse(textView.textContainer?.widthTracksTextView ?? true)
    }
}
