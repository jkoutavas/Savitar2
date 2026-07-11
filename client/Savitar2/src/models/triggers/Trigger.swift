//
//  Trigger.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/1/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let TriggerElemIdentifier = "TRIGGER"

enum TrigAppearance {
    case gag
    case dontUseStyle
    case changeAppearance
}

extension TrigAppearance {
    init() {
        self = .dontUseStyle
    }
}

enum TrigAudioType {
    case silent
    case sound
    case speakEvent
    case sayText
}

extension TrigAudioType {
    init() {
        self = .silent
    }
}

enum TrigMatching {
    case exact
    case wholeLine
    case wholeWord
}

extension TrigMatching {
    init() {
        self = .exact
    }
}

enum TrigSpecifier {
    case startsWith
    case lineContains
    case useRegex
}

extension TrigSpecifier {
    init() {
        self = .lineContains
    }
}

enum TrigType {
    case input
    case output
}

extension TrigType {
    init() {
        self = .output
    }
}

struct TrigFlags: OptionSet {
    let rawValue: Int

    static let exact = TrigFlags(rawValue: 1 << 0)
    static let toEndOfWord = TrigFlags(rawValue: 1 << 1)
    static let wholeLine = TrigFlags(rawValue: 1 << 2)
    static let disabled = TrigFlags(rawValue: 1 << 3)
    // static let useFore = TrigFlags(rawValue: 1 << 4)
    // v1.x flag replaced by the "foreColor" style flag in v2
    static let gag = TrigFlags(rawValue: 1 << 5)
    static let startsWith = TrigFlags(rawValue: 1 << 6)
    static let echoReply = TrigFlags(rawValue: 1 << 7)
    static let caseSensitive = TrigFlags(rawValue: 1 << 8)
    static let dontUseStyle = TrigFlags(rawValue: 1 << 9)
    static let useSubstitution = TrigFlags(rawValue: 1 << 10)
    static let useRegex = TrigFlags(rawValue: 1 << 11)
}

struct TriggerReaction {
    let matched: Bool
    let captures: [String: String]
}

private enum TriggerPatternPart {
    case literal(String)
    case wildcard(String?)
}

class Trigger: SavitarObject, NSCopying {
    public static let defaultName = "<new trigger>"

    // default settings
    var audioType: TrigAudioType = .silent
    var appearance: TrigAppearance = .dontUseStyle
    var matching: TrigMatching = .exact
    var specifier: TrigSpecifier = .lineContains
    var type: TrigType = .output
    var caseSensitive: Bool = false
    var enabled: Bool = true
    var useSubstitution: Bool = false
    var echoReply: Bool = false

    // optional settings
    var reply: String?
    var say: String?
    var sound: String?
    var style: TrigTextStyle?
    var substitution: String?
    var voice: String?
    var wordEnding: String?

    // transitory data (doesn't get loaded or saved)
    var matchedText = ""

    func copy(with _: NSZone? = nil) -> Any {
        return Trigger(trigger: self)
    }

    func getFlagsFromValues() -> TrigFlags {
        var flags = TrigFlags()

        switch appearance {
        case .dontUseStyle:
            flags.insert(.dontUseStyle)
        case .gag:
            flags.insert(.gag)
        case .changeAppearance:
            flags.remove([.dontUseStyle, .gag])
        }

        switch matching {
        case .exact:
            flags.insert(.exact)
        case .wholeLine:
            flags.insert(.wholeLine)
        case .wholeWord:
            flags.insert(.toEndOfWord)
        }

        switch specifier {
        case .startsWith:
            flags.insert(.startsWith)
        case .useRegex:
            flags.insert(.useRegex)
        case .lineContains:
            flags.remove([.startsWith, .useRegex])
        }

        if caseSensitive {
            flags.insert(.caseSensitive)
        }

        if !enabled {
            flags.insert(.disabled)
        }

        if useSubstitution {
            flags.insert(.useSubstitution)
        }

        if echoReply {
            flags.insert(.echoReply)
        }

        return flags
    }

    func setValuesFrom(flags: TrigFlags) {
        if flags.contains(.dontUseStyle) {
            appearance = .dontUseStyle
        } else if flags.contains(.gag) {
            appearance = .gag
        } else {
            appearance = .changeAppearance
        }

        if flags.contains(.exact) {
            matching = .exact
        } else if flags.contains(.wholeLine) {
            matching = .wholeLine
        } else if flags.contains(.toEndOfWord) {
            matching = .wholeWord
        }

        if flags.contains(.startsWith) {
            specifier = .startsWith
        } else if flags.contains(.useRegex) {
            specifier = .useRegex
        } else {
            specifier = .lineContains
        }

        caseSensitive = flags.contains(.caseSensitive)
        enabled = !flags.contains(.disabled)
        useSubstitution = flags.contains(.useSubstitution)
        echoReply = flags.contains(.echoReply)
    }

    var flags: TrigFlags {
        get { getFlagsFromValues() }
        set { setValuesFrom(flags: newValue) }
    }

    init(trigger: Trigger) {
        super.init()

        name = trigger.name
        audioType = trigger.audioType
        appearance = trigger.appearance
        matching = trigger.matching
        specifier = trigger.specifier
        type = trigger.type
        caseSensitive = trigger.caseSensitive
        enabled = trigger.enabled
        useSubstitution = trigger.useSubstitution
        echoReply = trigger.echoReply
        reply = trigger.reply
        say = trigger.say
        sound = trigger.sound
        style = trigger.style
        substitution = trigger.substitution
        type = trigger.type
        voice = trigger.voice
        wordEnding = trigger.wordEnding

        matchedText = trigger.matchedText
    }

    init(
        // default settings
        name: String = defaultName,
        flags: TrigFlags? = nil,
        audioCue: TrigAudioType = .silent,
        appearance: TrigAppearance = .changeAppearance,
        matching: TrigMatching = .exact,
        specifier: TrigSpecifier = .lineContains,
        type: TrigType = .output,
        caseSensitive: Bool = false,
        enabled: Bool = true,
        useSubstitution: Bool = false,
        echoReply: Bool = false,
        // optional settings
        reply: String? = nil,
        say: String? = nil,
        sound: String? = nil,
        style: TrigTextStyle? = nil,
        substitution: String? = nil,
        voice: String? = nil,
        wordEnding: String? = nil
    ) {
        super.init()

        self.name = name
        audioType = audioCue
        self.appearance = appearance
        self.matching = matching
        self.specifier = specifier
        self.type = type
        self.caseSensitive = caseSensitive
        self.enabled = enabled
        self.useSubstitution = useSubstitution
        self.echoReply = echoReply

        self.reply = reply
        self.say = say
        self.sound = sound
        self.substitution = substitution
        self.voice = voice
        self.wordEnding = wordEnding

        self.style = style
        if style != nil {
            self.style!.formOnOff()
        }

        if let f = flags {
            self.flags = f
        }
    }

    public func reactionTo(line: inout String) -> Bool {
        return reactionTo(line: &line, wildMarker: nil).matched
    }

    public func reactionTo(line: inout String, wildMarker: String?) -> TriggerReaction {
        var pattern = name
        var matched = false
        var captures: [String: String] = [:]

        matchedText = ""

        // TODO: optimization: form the options at trigger init / setting
        var options: String.CompareOptions = []
        if caseSensitive == false {
            options = .caseInsensitive
        }
        if specifier == .useRegex {
            options = [options, .regularExpression]
        } else if matching == .wholeWord {
            // end of word matching is easiest with a regex...
            pattern += "\\w*"
            options = [options, .regularExpression]
        } else if let wordEnding = self.wordEnding, wordEnding.count > 0 {
            // word ending matching is easiest with a regex...
            pattern += "\\w*[\(wordEnding)]"
            options = [options, .regularExpression]
        }

        var ranges: [Range<String.Index>]
        if let wildMarker = wildMarker,
           specifier != .useRegex,
           !wildMarker.isEmpty,
           name.contains(wildMarker) {
            let literalOptions = caseSensitive ? String.CompareOptions() : .caseInsensitive
            let variableMatch = wildcardMatches(in: line, wildMarker: wildMarker, options: literalOptions)
            ranges = variableMatch.ranges
            captures = variableMatch.captures
        } else {
            ranges = line.ranges(of: pattern, options: options)
            if specifier == .useRegex {
                captures = regexCaptures(in: line, pattern: pattern)
            }
        }
        matched = ranges.count > 0
        if ranges.count > 0, matching == .wholeLine {
            ranges = [line.fullRange]
        }
        var resultLine = ""
        var pos = line.startIndex
        for range in ranges {
            if pos != range.lowerBound {
                resultLine += line[pos ..< range.lowerBound]
                matchedText += line[pos ..< range.lowerBound]
            }
            if appearance != .gag {
                if let subst = substitution, useSubstitution {
                    if let style = self.style, appearance == .changeAppearance {
                        resultLine += style.on + subst + style.off
                        matchedText += subst
                    } else {
                        resultLine += subst
                        matchedText += subst
                    }
                } else if let style = self.style, appearance == .changeAppearance {
                    let content = line[range]
                    if content.hasSuffix("\r") || content.hasSuffix("\n") {
                        let suffix = content.suffix(1)
                        // Close-off trigger appearance styling before the line ending
                        resultLine += style.on + content.dropLast() + style.off + suffix
                    } else {
                        resultLine += style.on + content + style.off
                    }
                    matchedText += content
                } else {
                    resultLine = String(line[range])
                    matchedText = resultLine
                }
            }
            pos = range.upperBound
        }
        if pos < line.endIndex {
            resultLine += line[pos ..< line.endIndex]
        }
        line = resultLine

        return TriggerReaction(matched: matched, captures: captures)
    }

    private func regexCaptures(in line: String, pattern: String) -> [String: String] {
        var captures: [String: String] = [:]
        let options: NSRegularExpression.Options = caseSensitive ? [] : .caseInsensitive
        guard let expression = try? NSRegularExpression(pattern: pattern, options: options) else {
            return captures
        }

        let nsRange = NSRange(line.startIndex ..< line.endIndex, in: line)
        expression.enumerateMatches(in: line, options: [], range: nsRange) { match, _, _ in
            guard let match = match else { return }
            for index in 0 ..< match.numberOfRanges {
                let range = match.range(at: index)
                guard range.location != NSNotFound,
                      let swiftRange = Range(range, in: line) else { continue }
                captures["\(index)"] = String(line[swiftRange])
            }
        }

        return captures
    }

    private func wildcardMatches(in line: String, wildMarker: String,
                                 options: String.CompareOptions) -> (ranges: [Range<String.Index>],
                                                                     captures: [String: String]) {
        let parts = wildcardPatternParts(wildMarker: wildMarker)
        guard parts.contains(where: {
            if case .wildcard = $0 { return true }
            return false
        }) else {
            return ([], [:])
        }

        var ranges: [Range<String.Index>] = []
        var captures: [String: String] = [:]
        var searchStart = line.startIndex
        while searchStart < line.endIndex,
              let match = wildcardMatch(in: line, parts: parts, searchRange: searchStart ..< line.endIndex,
                                        options: options) {
            ranges.append(match.range)
            for capture in match.captures {
                captures[capture.key] = capture.value
            }

            guard match.range.upperBound > searchStart else { break }
            searchStart = match.range.upperBound
        }

        return (ranges, captures)
    }

    private func wildcardPatternParts(wildMarker: String) -> [TriggerPatternPart] {
        var parts: [TriggerPatternPart] = []
        var position = name.startIndex

        while position < name.endIndex,
              let markerRange = name.range(of: wildMarker, range: position ..< name.endIndex) {
            if markerRange.lowerBound > position {
                parts.append(.literal(String(name[position ..< markerRange.lowerBound])))
            }

            var variableEnd = markerRange.upperBound
            while variableEnd < name.endIndex,
                  VariableMan.isValidVariableCharacter(name[variableEnd]) {
                variableEnd = name.index(after: variableEnd)
            }

            let variableName = String(name[markerRange.upperBound ..< variableEnd])
            parts.append(.wildcard(variableName.isEmpty ? nil : variableName))
            position = variableEnd
        }

        if position < name.endIndex {
            parts.append(.literal(String(name[position ..< name.endIndex])))
        }

        return parts
    }

    private func wildcardMatch(in line: String, parts: [TriggerPatternPart], searchRange: Range<String.Index>,
                               options: String.CompareOptions) -> (range: Range<String.Index>,
                                                                   captures: [String: String])? {
        var position = searchRange.lowerBound
        var matchStart: String.Index?
        var captures: [String: String] = [:]
        var index = parts.startIndex

        while index < parts.endIndex {
            switch parts[index] {
            case let .literal(literal):
                if literal.isEmpty {
                    index = parts.index(after: index)
                    continue
                }

                guard let range = line.range(
                    of: literal,
                    options: options,
                    range: position ..< searchRange.upperBound
                ) else {
                    return nil
                }
                if matchStart == nil {
                    matchStart = range.lowerBound
                }
                position = range.upperBound

            case let .wildcard(variableName):
                if matchStart == nil {
                    matchStart = position
                }

                let captureStart = position
                let captureEnd: String.Index
                if let nextLiteral = nextLiteral(after: index, in: parts), !nextLiteral.isEmpty {
                    guard let nextRange = line.range(of: nextLiteral, options: options,
                                                     range: position ..< searchRange.upperBound) else {
                        return nil
                    }
                    captureEnd = nextRange.lowerBound
                    position = captureEnd
                } else {
                    captureEnd = line[captureStart ..< searchRange.upperBound].firstIndex(where: {
                        $0 == "\r" || $0 == "\n"
                    }) ?? searchRange.upperBound
                    position = captureEnd
                }

                if let variableName = variableName {
                    let name = caseSensitive ? variableName : variableName.lowercased()
                    captures[name] = String(line[captureStart ..< captureEnd])
                }
            }

            index = parts.index(after: index)
        }

        guard let lowerBound = matchStart else { return nil }
        return (lowerBound ..< position, captures)
    }

    private func nextLiteral(after index: [TriggerPatternPart].Index,
                             in parts: [TriggerPatternPart]) -> String? {
        var nextIndex = parts.index(after: index)
        while nextIndex < parts.endIndex {
            if case let .literal(literal) = parts[nextIndex] {
                return literal
            }
            nextIndex = parts.index(after: nextIndex)
        }
        return nil
    }

    let audioCueDict: [TrigAudioType: String] = [
        .silent: "silent",
        .sound: "sound",
        .speakEvent: "speakEvent",
        .sayText: "sayText"
    ]

    let typeDict: [TrigType: String] = [
        .input: "input",
        .output: "output"
    ]

    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

    let ReplyElemIdentifier = "REPLY"
    let SayElemIdentifier = "SAY"
    let SubsitutionElemIdentifier = "SUBSITUTION" // note v1 misspelling
    let SubstitutionElemIdentifier = "SUBSTITUTION" // note v2 correct spelling
    let WordEndElemIdentifier = "WORDEND"

    // These are the TriggerElemIdentifier attributes
    enum TriggerAttribIdentifier: String {
        // these are obsoleted in v2
        case color = "COLOR" // replaced by FGCOLOR in v2

        // these are shared between v1 and v2
        case name = "NAME"
        case type = "TYPE"
        case flags = "FLAGS"
        case face = "FACE"
        case audio = "AUDIO"
        case sound = "SOUND"
        case voice = "VOICE"
        case say = "SAY"
        case wordend = "WORDEND"

        // these are new for v2
        case version = "VERSION"
        case fgColor = "FGCOLOR" // replaces COLOR
        case bgColor = "BGCOLOR"
        case subst = "SUBST" // replaces SUBSITUTION (sic)
    }

    override func parse(xml: XML.Accessor) throws {
        let audioLabels: [String: TrigAudioType] = [
            "silent": .silent,
            "sound": .sound,
            "speakEvent": .speakEvent,
            "sayText": .sayText
        ]

        let typeLabels: [String: TrigType] = [
            "input": .input,
            "output": .output
        ]

        var hasUseFore = false
        for attribute in xml.attributes {
            switch attribute.key {
            case TriggerAttribIdentifier.audio.rawValue:
                if let type = audioLabels[attribute.value] {
                    audioType = type
                }
            case TriggerAttribIdentifier.bgColor.rawValue:
                if style == nil {
                    style = TrigTextStyle()
                }
                style!.backColor = NSColor(hex: attribute.value)
                if style!.face == nil {
                    style!.face = .backColor
                } else {
                    style!.face!.insert(.backColor)
                }
            case TriggerAttribIdentifier.color.rawValue, TriggerAttribIdentifier.fgColor.rawValue:
                if style == nil {
                    style = TrigTextStyle()
                }
                style!.foreColor = NSColor(hex: attribute.value)
                if style!.face == nil {
                    style!.face = .foreColor
                } else {
                    style!.face!.insert(.foreColor)
                }
            case TriggerAttribIdentifier.face.rawValue:
                if style == nil {
                    style = TrigTextStyle()
                }
                style!.face = TrigFace.from(string: attribute.value)
            case TriggerAttribIdentifier.flags.rawValue:
                let flags = TrigFlags.from(string: attribute.value)
                setValuesFrom(flags: flags)
                hasUseFore = attribute.value.contains("useFore") // only present in v1.x documents
            case TriggerAttribIdentifier.name.rawValue:
                name = attribute.value
            case TriggerAttribIdentifier.sound.rawValue:
                sound = attribute.value
            case TriggerAttribIdentifier.type.rawValue:
                if let type = typeLabels[attribute.value] {
                    self.type = type
                } else {
                    type = .input // we no longer support trigger type "both"
                }
            case TriggerAttribIdentifier.voice.rawValue:
                voice = attribute.value
            default:
                print("skipping trigger attribute \(attribute.key)")
            }
        }
        if hasUseFore {
            // In v1.x, "useFore" signifies "use the current world's foreground color, don't set a foreground
            // color for the trigger. In v2.0, we translate the v1.x "useFore" flag to mean, "set the face's
            // "foreColor" if there's not a v1.x "useFor" flag." Basically, we're saying:
            //      face.foreColor == !flags.useFore
            if style != nil {
                if style!.face != nil {
                    style!.face!.remove(.foreColor)
                }
            }
        }

        if let text = xml[ReplyElemIdentifier].text {
            reply = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[SayElemIdentifier].text {
            say = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[SubsitutionElemIdentifier].text {
            substitution = text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let text = xml[SubstitutionElemIdentifier].text {
            substitution = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[WordEndElemIdentifier].text {
            wordEnding = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    override func toXMLElement() throws -> XMLElement {
        let trigElem = XMLElement(name: TriggerElemIdentifier)

        trigElem.addAttribute(name: TriggerAttribIdentifier.name.rawValue, stringValue: name)

        if let value = typeDict[type] {
            trigElem.addAttribute(name: TriggerAttribIdentifier.type.rawValue, stringValue: value)
        }

        trigElem.addAttribute(name: TriggerAttribIdentifier.flags.rawValue,
                              stringValue: getFlagsFromValues().description)

        if let value = wordEnding {
            trigElem.addChild(
                XMLElement(name: WordEndElemIdentifier, stringValue: value))
        }

        if let value = style?.face?.description {
            if value.count > 0 {
                trigElem.addAttribute(name: TriggerAttribIdentifier.face.rawValue, stringValue: value)
            }
        }

        if let value = style?.backColor?.toHex() {
            trigElem.addAttribute(name: TriggerAttribIdentifier.bgColor.rawValue, stringValue: "#\(value)")
        }

        if let value = style?.foreColor?.toHex() {
            trigElem.addAttribute(name: TriggerAttribIdentifier.fgColor.rawValue, stringValue: "#\(value)")
        }

        if let value = sound {
            trigElem.addAttribute(name: TriggerAttribIdentifier.sound.rawValue, stringValue: value)
        }

        if let value = audioCueDict[audioType] {
            trigElem.addAttribute(name: TriggerAttribIdentifier.audio.rawValue, stringValue: value)
        }

        if let value = voice {
            trigElem.addAttribute(name: TriggerAttribIdentifier.voice.rawValue, stringValue: value)
        }

        if let value = reply {
            trigElem.addChild(
                XMLElement(name: ReplyElemIdentifier, stringValue: value))
        }

        if let value = say {
            trigElem.addChild(
                XMLElement(name: SayElemIdentifier, stringValue: value))
        }

        if let value = substitution {
            trigElem.addChild(
                XMLElement(name: SubstitutionElemIdentifier, stringValue: value))
        }

        return trigElem
    }
}

extension TrigFlags: StrOptionSet {
    // TODO: I wonder if there's a DRY-er way to do these
    static var labels: [Label] { return [
        (.exact, "matchExactly"),
        (.toEndOfWord, "matchToEndOfWord"),
        (.wholeLine, "matchWholeLine"),
        (.disabled, "disabled"),
        (.gag, "gag"),
        (.startsWith, "matchAtStart"),
        (.echoReply, "echoReply"),
        (.caseSensitive, "caseSensitive"),
        (.dontUseStyle, "dontUseStyle"),
        (.useSubstitution, "useSubstitution"), // Note: new label correct spelling for v2
        (.useRegex, "useRegex")
    ] }
    static var labelDict: [String: Self] { return [
        "matchExactly": .exact,
        "matchToEndOfWord": .toEndOfWord,
        "matchWholeLine": .wholeLine,
        "disabled": .disabled,
        "gag": .gag,
        "matchAtStart": .startsWith,
        "echoReply": .echoReply,
        "caseSensitive": .caseSensitive,
        "dontUseStyle": .dontUseStyle,
        "useSubstitution": .useSubstitution, // Note: new v2.0 correctly spelled label
        "useSubsitution": .useSubstitution, // Note: old (misspelled) v1.0 label
        "useRegex": .useRegex
    ] }
}
