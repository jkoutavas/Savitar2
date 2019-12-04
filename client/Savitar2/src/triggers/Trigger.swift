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
    static let useSubsitution = TrigFlags(rawValue: 1 << 10)
    static let useRegex = TrigFlags(rawValue: 1 << 11)
}

struct Trigger {
    let name: String?
    let type: TrigType?
    let flags: TrigFlags?
    let wordEnding: String?
    let subsitution: String?

    init(name: String? = nil,
         type: TrigType? = nil,
         flags: TrigFlags? = nil,
         wordEnding: String? = nil,
         subsitution: String? = nil) {

        self.name = name
        self.type = type
        self.flags = flags
        self.wordEnding = wordEnding
        self.subsitution = subsitution
    }

    public func reactionTo(line: String, options: String.CompareOptions = []) -> String {
        switch flags! {
        case [.caseSensitive, .exact]:
            return reactTo(line: line)
        case .exact:
             return reactTo(line: line, options: .caseInsensitive)
        case .useRegex:
            return reactTo(line: line, options: [.regularExpression, .caseInsensitive])
        case [.useRegex, .caseSensitive]:
            return reactTo(line: line, options: .regularExpression)
        case .wholeLine:
            let found = (flags?.contains([.exact]))!
                ? line.contains(name!) : line.localizedCaseInsensitiveContains(name!)
            if found {
                return "<span class=green>\(line)</span>"
            }
        default:
            // TODO: add logging
            print("trigger '\(name!)' was skipped.")
        }
        return line
    }

    private func reactTo(line: String, options: String.CompareOptions = []) -> String {
        let ranges = line.ranges(of: name!, options: options)
        var reassembledLine = ""
        var position = line.startIndex
        for range in ranges {
            if position != range.lowerBound {
                reassembledLine += line[position..<range.lowerBound]
            }
            reassembledLine += "<span class='blink'>\(line[range])</span>"
            position = range.upperBound
        }
        if position < line.endIndex {
             reassembledLine += line[position..<line.endIndex]
        }
        return reassembledLine
    }
}
