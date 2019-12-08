//
//  Trigger.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/1/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

enum TrigType {
    case Unknown
    case Incoming
    case Outgoing
    case AnyText
}

struct TrigFlags: OptionSet {
    let rawValue: Int

    static let exact = TrigFlags(rawValue: 1 << 0)
    static let toEndOfWord = TrigFlags(rawValue: 1 << 1)
    static let wholeLine = TrigFlags(rawValue: 1 << 2)
    static let disabled = TrigFlags(rawValue: 1 << 3)
    static let useFore = TrigFlags(rawValue: 1 << 4)
    static let gag = TrigFlags(rawValue: 1 << 5)
    static let startsWith = TrigFlags(rawValue: 1 << 6)
    static let echoReply = TrigFlags(rawValue: 1 << 7)
    static let caseSensitive = TrigFlags(rawValue: 1 << 8)
    static let dontUseStyle = TrigFlags(rawValue: 1 << 9)
    static let useSubstitution = TrigFlags(rawValue: 1 << 10)
    static let useRegex = TrigFlags(rawValue: 1 << 11)
}

struct Trigger: Equatable {
    // default settings
    var name: String = "<new trigger>"
    var type: TrigType = .Outgoing
    var flags: TrigFlags = .exact

    // optional settings
    var style: TrigTextStyle?
    var wordEnding: String?
    var substitution: String?

    init(name: String,
         type: TrigType? = nil,
         flags: TrigFlags? = nil,
         style: TrigTextStyle? = nil,
         wordEnding: String? = nil,
         substitution: String? = nil) {

        self.name = name

        if let t = type {
            self.type = t
        }
        if let f = flags {
            self.flags = f
        }
        self.style = style
        self.wordEnding = wordEnding
        self.substitution = substitution
    }

    public func reactionTo(line: String) -> String {
        var pattern = name

        // TODO: optimization: form the options at trigger init / setting
        var options: String.CompareOptions = []
        if flags.contains(.caseSensitive) == false {
            options = .caseInsensitive
        }
        if flags.contains(.useRegex) {
            options = [options, .regularExpression]
        } else if flags.contains(.toEndOfWord) {
            // end of word matching is easiest with a regex...
            pattern += "\\w*"
            options = [options, .regularExpression]
        } else if let wordEnding = self.wordEnding, wordEnding.count > 0 {
            // word ending matching is easiest with a regex...
            pattern += "\\w*[\(wordEnding)]"
            options = [options, .regularExpression]
        }

        var ranges = line.ranges(of: pattern, options: options)
        if ranges.count > 0 && flags.contains(.wholeLine) {
            ranges = [line.fullRange]
        }
        var resultLine = ""
        var pos = line.startIndex
        for range in ranges {
            if pos != range.lowerBound {
                resultLine += line[pos..<range.lowerBound]
            }
            if flags.contains(.gag) == false {
                if let subst = self.substitution, flags.contains(.useSubstitution) {
                    if let style = self.style {
                        resultLine += style.on + subst + style.off
                    } else {
                        resultLine += subst
                    }
                } else if let style = self.style {
                    resultLine += style.on + line[range] + style.off
                } else {
                    resultLine = String(line[range])
                }
            }
            pos = range.upperBound
        }
        if pos < line.endIndex {
             resultLine += line[pos..<line.endIndex]
        }
        return resultLine
    }
}
