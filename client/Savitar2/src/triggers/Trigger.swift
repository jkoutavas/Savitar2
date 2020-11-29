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

enum TrigAudioType {
    case silent
    case sound
    case speakEvent
    case sayText
}

enum TrigMatching {
    case exact
    case wholeLine
    case wholeWord
}

enum TrigSpecifier {
    case startsWith
    case lineContains
    case useRegex
}

enum TrigType {
    case input
    case output
    case both
}

struct TrigFlags: OptionSet {
    let rawValue: Int

    static let exact = TrigFlags(rawValue: 1 << 0)
    static let toEndOfWord = TrigFlags(rawValue: 1 << 1)
    static let wholeLine = TrigFlags(rawValue: 1 << 2)
    static let disabled = TrigFlags(rawValue: 1 << 3)
    //    static let useFore = TrigFlags(rawValue: 1 << 4) // this v1.x flag is replaced by the "foreColor" style flag in v2
    static let gag = TrigFlags(rawValue: 1 << 5)
    static let startsWith = TrigFlags(rawValue: 1 << 6)
    static let echoReply = TrigFlags(rawValue: 1 << 7)
    static let caseSensitive = TrigFlags(rawValue: 1 << 8)
    static let dontUseStyle = TrigFlags(rawValue: 1 << 9)
    static let useSubstitution = TrigFlags(rawValue: 1 << 10)
    static let useRegex = TrigFlags(rawValue: 1 << 11)
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

    func copy(with zone: NSZone? = nil) -> Any {
        return Trigger(trigger: self)
    }

    func getFlagsFromValues() -> TrigFlags {
        var flags = TrigFlags()

        switch self.appearance {
        case .dontUseStyle:
            flags.insert(.dontUseStyle)
        case .gag:
            flags.insert(.gag)
        case .changeAppearance:
            flags.remove([.dontUseStyle, .gag])
        }

        switch self.matching {
        case .exact:
            flags.insert(.exact)
        case .wholeLine:
            flags.insert(.wholeLine)
        case .wholeWord:
            flags.insert(.toEndOfWord)
        }

        switch self.specifier {
        case .startsWith:
            flags.insert(.startsWith)
        case .useRegex:
            flags.insert(.useRegex)
        case .lineContains:
            flags.remove([.startsWith, .useRegex])
        }

        if self.caseSensitive {
            flags.insert(.caseSensitive)
        }

        if !self.enabled {
            flags.insert(.disabled)
        }

        if self.useSubstitution {
            flags.insert(.useSubstitution)
        }

        if self.echoReply {
            flags.insert(.echoReply)
        }

        return flags
    }

    func setValuesFrom(flags: TrigFlags) {
        if flags.contains(.dontUseStyle) {
            self.appearance = .dontUseStyle
        } else if flags.contains(.gag) {
            self.appearance = .gag
        } else {
            self.appearance = .changeAppearance
        }

        if flags.contains(.exact) {
            self.matching = .exact
        } else if flags.contains(.wholeLine) {
            self.matching = .wholeLine
        } else if flags.contains(.toEndOfWord) {
            self.matching = .wholeWord
        }

        if flags.contains(.startsWith) {
            self.specifier = .startsWith
        } else if flags.contains(.useRegex) {
            self.specifier = .useRegex
        } else {
            self.specifier = .lineContains
        }

        self.caseSensitive = flags.contains(.caseSensitive)
        self.enabled = !flags.contains(.disabled)
        self.useSubstitution = flags.contains(.useSubstitution)
        self.echoReply = flags.contains(.echoReply)
    }

    var flags: TrigFlags {
        get { getFlagsFromValues() }
        set { setValuesFrom(flags: newValue) }
    }

    init(trigger: Trigger) {
        super.init()

        self.name = trigger.name
        self.audioType = trigger.audioType
        self.appearance = trigger.appearance
        self.matching = trigger.matching
        self.specifier = trigger.specifier
        self.type = trigger.type
        self.caseSensitive = trigger.caseSensitive
        self.enabled = trigger.enabled
        self.useSubstitution = trigger.useSubstitution
        self.echoReply = trigger.echoReply
        self.reply = trigger.reply
        self.say = trigger.say
        self.sound = trigger.sound
        self.style = trigger.style
        self.substitution = trigger.substitution
        self.type = trigger.type
        self.voice = trigger.voice
        self.wordEnding = trigger.wordEnding
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
        wordEnding: String? = nil) {

        super.init()

        self.name = name
        self.audioType = audioCue
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
        var pattern = name
        var matched = false

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

        var ranges = line.ranges(of: pattern, options: options)
        matched = ranges.count > 0
        if ranges.count > 0 && matching == .wholeLine {
            ranges = [line.fullRange]
        }
        var resultLine = ""
        var pos = line.startIndex
        for range in ranges {
            if pos != range.lowerBound {
                resultLine += line[pos..<range.lowerBound]
            }
            if appearance != .gag {
                if let subst = self.substitution, useSubstitution {
                    if let style = self.style, appearance == .changeAppearance {
                        resultLine += style.on + subst + style.off
                    } else {
                        resultLine += subst
                    }
                } else if let style = self.style, appearance == .changeAppearance {
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
        line = resultLine
        return matched
    }

    let audioCueDict: [TrigAudioType: String] = [
        .silent: "silent",
        .sound: "sound",
        .speakEvent: "speakEvent",
        .sayText: "sayText"
    ]

    let typeDict: [TrigType: String] = [
        .input: "input",
        .output: "output",
        .both: "both"
    ]

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

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
            "output": .output,
            "both": .both
        ]

        var hasUseFore = false
        for attribute in xml.attributes {
            switch attribute.key {
            case TriggerAttribIdentifier.audio.rawValue:
                if let type = audioLabels[attribute.value] {
                    self.audioType = type
                }
            case TriggerAttribIdentifier.bgColor.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.backColor = NSColor(hex: attribute.value)
                if self.style!.face == nil {
                    self.style!.face = .backColor
                } else {
                    self.style!.face!.insert(.backColor)
                }
            case TriggerAttribIdentifier.color.rawValue, TriggerAttribIdentifier.fgColor.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.foreColor = NSColor(hex: attribute.value)
                if self.style!.face == nil {
                    self.style!.face = .foreColor
                } else {
                    self.style!.face!.insert(.foreColor)
                }
            case TriggerAttribIdentifier.face.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.face = TrigFace.from(string: attribute.value)
            case TriggerAttribIdentifier.flags.rawValue:
                let flags = TrigFlags.from(string: attribute.value)
                setValuesFrom(flags: flags)
                hasUseFore = attribute.value.contains("useFore") // only present in v1.x documents
            case TriggerAttribIdentifier.name.rawValue:
                self.name = attribute.value
            case TriggerAttribIdentifier.sound.rawValue:
                self.sound = attribute.value
            case TriggerAttribIdentifier.type.rawValue:
                if let type = typeLabels[attribute.value] {
                    self.type = type
                }
            case TriggerAttribIdentifier.voice.rawValue:
                self.voice = attribute.value
            default:
                print("skipping trigger attribute \(attribute.key)")
            }
        }
        if hasUseFore {
            // In v1.x, "useFore" signifies "use the current world's foreground color, don't set a foreground
            // color for the trigger. In v2.0, we translate the v1.x "useFore" flag to mean, "set the face's
            // "foreColor" if there's not a v1.x "useFor" flag." Basically, we're saying:
            //      face.foreColor == !flags.useFore
            if self.style != nil {
                if self.style!.face != nil {
                    self.style!.face!.remove(.foreColor)
                }
            }
        }

        if let text = xml[ReplyElemIdentifier].text {
            self.reply = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[SayElemIdentifier].text {
            self.say = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[SubsitutionElemIdentifier].text {
            self.substitution = text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let text = xml[SubstitutionElemIdentifier].text {
            self.substitution = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let text = xml[WordEndElemIdentifier].text {
            self.wordEnding = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    override func toXMLElement() throws -> XMLElement {
        let trigElem = XMLElement(name: TriggerElemIdentifier)

        trigElem.addAttribute(name: TriggerAttribIdentifier.name.rawValue, stringValue: self.name)

        if let value = typeDict[self.type] {
            trigElem.addAttribute(name: TriggerAttribIdentifier.type.rawValue, stringValue: value)
        }

        trigElem.addAttribute(name: TriggerAttribIdentifier.flags.rawValue,
                       stringValue: getFlagsFromValues().description)

        if let value = self.wordEnding {
            trigElem.addChild(
                XMLElement.init(name: WordEndElemIdentifier, stringValue: value))
        }

        if let value = self.style?.face?.description {
            if value.count > 0 {
                trigElem.addAttribute(name: TriggerAttribIdentifier.face.rawValue, stringValue: value)
            }
        }

        if let value = self.style?.backColor?.toHex() {
            trigElem.addAttribute(name: TriggerAttribIdentifier.bgColor.rawValue, stringValue: "#\(value)")
        }

        if let value = self.style?.foreColor?.toHex() {
            trigElem.addAttribute(name: TriggerAttribIdentifier.fgColor.rawValue, stringValue: "#\(value)")
        }

        if let value = self.sound {
            trigElem.addAttribute(name: TriggerAttribIdentifier.sound.rawValue, stringValue: value)
        }

        if let value = audioCueDict[self.audioType] {
            trigElem.addAttribute(name: TriggerAttribIdentifier.audio.rawValue, stringValue: value)
        }

        if let value = self.voice {
            trigElem.addAttribute(name: TriggerAttribIdentifier.voice.rawValue, stringValue: value)
        }

        if let value = self.reply {
            trigElem.addChild(
                XMLElement.init(name: ReplyElemIdentifier, stringValue: value))
        }

        if let value = self.say {
            trigElem.addChild(
                XMLElement.init(name: SayElemIdentifier, stringValue: value))
        }

        if let value = self.substitution {
            trigElem.addChild(
                XMLElement.init(name: SubstitutionElemIdentifier, stringValue: value))
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
        ]}
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
        ]}
}
