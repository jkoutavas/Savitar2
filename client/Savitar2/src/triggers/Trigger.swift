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

struct TrigFace: OptionSet {
    let rawValue: Int

    static let normal = TrigFace(rawValue: 1 << 0)
    static let bold = TrigFace(rawValue: 1 << 1)
    static let italic = TrigFace(rawValue: 1 << 2)
    static let underline = TrigFace(rawValue: 1 << 3)
}

struct TrigTextStyle {
    let face: TrigFace
    let foreColor: String
    let backColor: String
}

struct TrigFlags: OptionSet {
    let rawValue: Int

    static let exact = TrigFlags(rawValue: 1 << 0)
    static let endOfWord = TrigFlags(rawValue: 1 << 1) // TODO: obsolete this?
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
    let ansiBlink = "\u{1B}[5m"
    let ansiBlinkOff = "\u{1B}[25m"
    let ansiReset = "\u{1B}[0m"
    let ansiUnderline = "\u{1B}[4m"
    let ansiUnderlineOff = "\u{1B}[23m"

    let name: String?
    let type: TrigType?
    let flags: TrigFlags?
    let wordEnding: String?
    let substitution: String?

    static func == (lhs: Trigger, rhs: Trigger) -> Bool {
        return lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.flags == rhs.flags &&
               lhs.wordEnding == rhs.wordEnding &&
               lhs.substitution == rhs.substitution
    }

    init(name: String? = nil,
         type: TrigType? = nil,
         flags: TrigFlags? = nil,
         wordEnding: String? = nil,
         substitution: String? = nil) {

        self.name = name
        self.type = type
        self.flags = flags
        self.wordEnding = wordEnding
        self.substitution = substitution
    }

    public func reactionTo(line: String) -> String {
        var options: String.CompareOptions = []
        if flags!.contains(.caseSensitive) == false {
            options = .caseInsensitive
        }
        if flags!.contains(.useRegex) {
            options = [options, .regularExpression]
        }
        var ranges = line.ranges(of: name!, options: options)
        if ranges.count > 0 && flags!.contains(.wholeLine) {
            ranges = [line.fullRange]
        }
        var reassembledLine = ""
        var position = line.startIndex
        for range in ranges {
            if position != range.lowerBound {
                reassembledLine += line[position..<range.lowerBound]
            }
            if flags!.contains(.gag) == false {
                if flags!.contains(.useSubstitution) {
                    reassembledLine += ansiBlink + substitution! + ansiBlinkOff
                } else {
                    reassembledLine += ansiBlink + line[range] + ansiBlinkOff
                }
            }
            position = range.upperBound
        }
        if position < line.endIndex {
             reassembledLine += line[position..<line.endIndex]
        }
        return reassembledLine
    }
}
