//
//  PaneDimensions.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Maps between world `RESOLUTION` (columns × output rows × input rows), window content size,
/// and split-view layout. Matches Savitar 1 `CTVWorld` resolution math.
enum PaneDimensions {
    private static let verticalScrollbarWidth: CGFloat = 0
    /// Savitar 1 counts one extra input row for the input scroll view chrome.
    private static let inputChromeRows: CGFloat = 1

    static func charWidth(for font: NSFont) -> CGFloat {
        // Savitar 1 cell width for Monaco 9 is 6 px (480÷80); scale proportionally with point size.
        ceil(font.pointSize * (6.0 / 9.0))
    }

    static func lineHeight(for font: NSFont) -> CGFloat {
        // Savitar 1 cell height for 9 pt Monaco is 10 px (270÷27 rows including input chrome).
        ceil(font.pointSize + 1.0)
    }

    static func contentSize(columns: Int,
                            outputRows: Int,
                            inputRows: Int,
                            font: NSFont,
                            dividerThickness: CGFloat) -> NSSize {
        let width = charWidth(for: font) * CGFloat(max(columns, 1)) + verticalScrollbarWidth
        let rowCount = CGFloat(max(outputRows, 1) + max(inputRows, 1)) + inputChromeRows
        let height = lineHeight(for: font) * rowCount + dividerThickness
        return NSSize(width: ceil(width), height: ceil(height))
    }

    static func effectiveContentSize(for world: World, font: NSFont, dividerThickness: CGFloat) -> NSSize {
        if world.windowSize.width > 0, world.windowSize.height > 0 {
            return world.windowSize
        }
        return contentSize(columns: world.columns,
                           outputRows: world.outputRows,
                           inputRows: world.inputRows,
                           font: font,
                           dividerThickness: dividerThickness)
    }

    static func splitPosition(outputRows: Int, inputRows: Int, font: NSFont, contentHeight: CGFloat,
                              dividerThickness: CGFloat) -> CGFloat {
        let inputHeight = lineHeight(for: font) * (CGFloat(max(inputRows, 1)) + inputChromeRows)
        return max(0, contentHeight - dividerThickness - inputHeight)
    }

    static func apply(world: World,
                      to window: NSWindow,
                      splitView: NSSplitView,
                      font: NSFont) {
        guard splitView.subviews.count >= 2 else { return }

        let dividerThickness = splitView.dividerThickness
        let contentSize = effectiveContentSize(for: world, font: font, dividerThickness: dividerThickness)

        window.setContentSize(contentSize)

        let split = splitPosition(outputRows: world.outputRows,
                                  inputRows: world.inputRows,
                                  font: font,
                                  contentHeight: contentSize.height,
                                  dividerThickness: dividerThickness)
        splitView.setPosition(split, ofDividerAt: 0)
    }

    static func measure(world: inout World,
                        window: NSWindow,
                        splitView: NSSplitView,
                        font: NSFont) {
        let dividerThickness = splitView.dividerThickness
        let contentSize = window.contentRect(forFrameRect: window.frame).size
        let charW = max(charWidth(for: font), 1)
        let lineH = max(lineHeight(for: font), 1)

        world.windowSize = contentSize
        world.columns = max(1, Int(floor((contentSize.width - verticalScrollbarWidth) / charW)))

        let split = splitView.subviews.first.map { $0.frame.height } ?? 0
        world.outputRows = max(1, Int(floor(split / lineH)))

        let inputHeight = contentSize.height - split - dividerThickness
        let inputRowCount = inputHeight / lineH - inputChromeRows
        world.inputRows = max(1, Int(round(inputRowCount)))
    }

    static func resolutionLabel(columns: Int, outputRows: Int, inputRows: Int) -> String {
        "\(outputRows)×\(columns)"
    }
}
