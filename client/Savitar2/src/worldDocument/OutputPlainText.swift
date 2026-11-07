//
//  OutputPlainText.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

/// Plain text shared by continuous speech, session logging, and `##capture`.
///
/// ANSI is always removed. HTML tags and entities are interpreted only when the world
/// has Interpret HTML tags on, so a literal `<HP …>` prompt survives when that flag is off.
///
/// `ansiParser` is copied. Callers keep the display parser's split-sequence buffer intact
/// by passing the parser value from before the display parse, not the parser afterward.
enum OutputPlainText {
    static func string(from displayString: String,
                       interpretHTML: Bool,
                       ansiParser: Ansi2HtmlParser) -> String {
        let normalized = displayString
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        var parser = ansiParser
        let stripped = parser.parse(ansi: normalized, hideANSI: true)
        guard interpretHTML else { return stripped }
        return htmlToPlainText(stripped)
    }

    private static let namedEntities = [
        "amp": "&",
        "lt": "<",
        "gt": ">",
        "quot": "\"",
        "apos": "'",
        "nbsp": "\u{00A0}"
    ]

    private static let blockNames: Set<String> = [
        "p", "div", "pre", "blockquote", "li", "tr", "table",
        "h1", "h2", "h3", "h4", "h5", "h6"
    ]

    private struct HTMLTag {
        var name: String
        var isClosing: Bool
        var end: String.Index
    }

    private struct DecodedEntity {
        var value: String
        var next: String.Index
    }

    private static func htmlToPlainText(_ html: String) -> String {
        var output = ""
        var index = html.startIndex
        while index < html.endIndex {
            let character = html[index]
            if character == "&", let entity = decodeEntity(html, at: index) {
                output.append(entity.value)
                index = entity.next
                continue
            }
            if character == "<" {
                if let end = consumeDeclaration(html, from: index) {
                    index = end
                    continue
                }
                if let tag = parseTag(html, from: index) {
                    appendLineBreak(for: tag, to: &output)
                    if !tag.isClosing, tag.name == "script" || tag.name == "style" {
                        index = skipRawTextElement(html, from: tag.end, name: tag.name)
                    } else {
                        index = tag.end
                    }
                    continue
                }
            }
            output.append(character)
            index = html.index(after: index)
        }
        return output
    }

    private static func appendLineBreak(for tag: HTMLTag, to output: inout String) {
        let structural = tag.name == "br" || blockNames.contains(tag.name)
        guard structural else { return }
        if tag.name == "br" {
            output.append("\n")
            return
        }
        if tag.isClosing || !output.isEmpty {
            if !output.hasSuffix("\n") {
                output.append("\n")
            }
        }
    }

    private static func consumeDeclaration(_ html: String, from start: String.Index) -> String.Index? {
        let bang = html.index(after: start)
        guard bang < html.endIndex, html[bang] == "!" else { return nil }
        let afterBang = html.index(after: bang)
        if html[afterBang...].hasPrefix("--") {
            if let range = html.range(of: "-->", range: afterBang ..< html.endIndex) {
                return range.upperBound
            }
            return html.endIndex
        }
        if let end = html[start...].firstIndex(of: ">") {
            return html.index(after: end)
        }
        return html.endIndex
    }

    private static func parseTag(_ html: String, from start: String.Index) -> HTMLTag? {
        guard html[start] == "<" else { return nil }
        var index = html.index(after: start)
        guard index < html.endIndex else { return nil }

        var closing = false
        if html[index] == "/" {
            closing = true
            index = html.index(after: index)
            guard index < html.endIndex else { return nil }
        }
        guard isASCIILetter(html[index]) else { return nil }

        let nameStart = index
        index = html.index(after: index)
        while index < html.endIndex, isASCIIName(html[index]) {
            index = html.index(after: index)
        }
        let name = String(html[nameStart ..< index]).lowercased()

        var quote: Character?
        while index < html.endIndex {
            let character = html[index]
            if let openQuote = quote {
                if character == openQuote {
                    quote = nil
                }
            } else if character == "\"" || character == "'" {
                quote = character
            } else if character == ">" {
                return HTMLTag(name: name, isClosing: closing, end: html.index(after: index))
            }
            index = html.index(after: index)
        }
        return nil
    }

    private static func skipRawTextElement(_ html: String, from start: String.Index, name: String) -> String.Index {
        var index = start
        while index < html.endIndex {
            if html[index] == "<",
               let tag = parseTag(html, from: index),
               tag.isClosing,
               tag.name == name {
                return tag.end
            }
            index = html.index(after: index)
        }
        return html.endIndex
    }

    private static func decodeEntity(_ html: String, at start: String.Index) -> DecodedEntity? {
        guard html[start] == "&" else { return nil }
        var index = html.index(after: start)
        guard index < html.endIndex else { return nil }

        let limit = 32
        var scanned = 0
        if html[index] == "#" {
            index = html.index(after: index)
            scanned += 1
            guard index < html.endIndex else { return nil }
            let hex = html[index] == "x" || html[index] == "X"
            if hex {
                index = html.index(after: index)
                scanned += 1
            }
            let digitStart = index
            while index < html.endIndex, scanned < limit, html[index] != ";" {
                let character = html[index]
                let valid = hex ? isASCIIHex(character) : isASCIIDigit(character)
                if !valid { return nil }
                index = html.index(after: index)
                scanned += 1
            }
            guard index < html.endIndex, html[index] == ";", index > digitStart else { return nil }
            let digits = String(html[digitStart ..< index])
            let code = hex ? Int(digits, radix: 16) : Int(digits, radix: 10)
            guard let code, let scalar = Unicode.Scalar(code) else { return nil }
            return DecodedEntity(value: String(Character(scalar)), next: html.index(after: index))
        }

        let nameStart = index
        while index < html.endIndex, scanned < limit, html[index] != ";" {
            if !isASCIIName(html[index]) { return nil }
            index = html.index(after: index)
            scanned += 1
        }
        guard index < html.endIndex, html[index] == ";", index > nameStart else { return nil }
        let name = String(html[nameStart ..< index]).lowercased()
        guard let value = namedEntities[name] else { return nil }
        return DecodedEntity(value: value, next: html.index(after: index))
    }

    private static func isASCIILetter(_ character: Character) -> Bool {
        return character.isASCII && character.isLetter
    }

    private static func isASCIIDigit(_ character: Character) -> Bool {
        return character.isASCII && character.isNumber
    }

    private static func isASCIIHex(_ character: Character) -> Bool {
        return character.isASCII && character.isHexDigit
    }

    private static func isASCIIName(_ character: Character) -> Bool {
        return isASCIILetter(character) || isASCIIDigit(character)
    }
}
