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

enum TrigType {
    case unknown
    case input
    case output
    case both
}

enum AudioType {
    case silent
    case sound
    case speakEvent
    case sayText
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

class Trigger: SavitarObject, NSCopying {
    public static let defaultName = "<new trigger>"

    // default settings
    var audioCue: AudioType = .silent
    var flags: TrigFlags = .exact
    var type: TrigType = .output

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

    init(trigger: Trigger) {
        super.init()

        self.name = trigger.name
        self.audioCue = trigger.audioCue
        self.flags = trigger.flags
        self.reply = trigger.reply
        self.say = trigger.say
        self.sound = trigger.sound
        self.style = trigger.style
        self.substitution = trigger.substitution
        self.type = trigger.type
        self.voice = trigger.voice
        self.wordEnding = trigger.wordEnding
    }

    init(name: String? = nil,
         audio: AudioType? = nil,
         flags: TrigFlags? = nil,
         reply: String? = nil,
         say: String? = nil,
         sound: String? = nil,
         style: TrigTextStyle? = nil,
         substitution: String? = nil,
         type: TrigType? = nil,
         voice: String? = nil,
         wordEnding: String? = nil) {

        super.init()

        self.name = name ?? Self.defaultName

        if let a = audio {
            self.audioCue = a
        }
        if let t = type {
            self.type = t
        }
        if let f = flags {
            self.flags = f
        }
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

    let audioCueDict: [AudioType: String] = [
        .silent: "silent",
        .sound: "sound",
        .speakEvent: "speakEvent",
        .sayText: "sayText"
    ]

    let typeDict: [TrigType: String] = [
        .unknown: "unknown",
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
        let audioLabels: [String: AudioType] = [
            "silent": .silent,
            "sound": .sound,
            "speakEvent": .speakEvent,
            "sayText": .sayText
        ]

        let typeLabels: [String: TrigType] = [
            "unknown": .unknown,
            "input": .input,
            "output": .output,
            "both": .both
        ]

        for attribute in xml.attributes {
            switch attribute.key {
            case TriggerAttribIdentifier.audio.rawValue:
                if let type = audioLabels[attribute.value] {
                    self.audioCue = type
                } else {
                    self.audioCue = .silent
                }
            case TriggerAttribIdentifier.bgColor.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.backColor = NSColor(hex: attribute.value)
            case TriggerAttribIdentifier.color.rawValue, TriggerAttribIdentifier.fgColor.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.foreColor = NSColor(hex: attribute.value)
            case TriggerAttribIdentifier.face.rawValue:
                if self.style == nil {
                    self.style = TrigTextStyle()
                }
                self.style!.face = TrigFace.from(string: attribute.value)
            case TriggerAttribIdentifier.flags.rawValue:
                self.flags = TrigFlags.from(string: attribute.value)
            case TriggerAttribIdentifier.name.rawValue:
                self.name = attribute.value
            case TriggerAttribIdentifier.sound.rawValue:
                self.sound = attribute.value
            case TriggerAttribIdentifier.type.rawValue:
                if let type = typeLabels[attribute.value] {
                    self.type = type
                } else {
                    self.type = .unknown
                }
            case TriggerAttribIdentifier.voice.rawValue:
                self.voice = attribute.value
            default:
                print("skipping trigger attribute \(attribute.key)")
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

        trigElem.addAttribute(name: TriggerAttribIdentifier.flags.rawValue, stringValue: self.flags.description)

        if let value = self.wordEnding {
            trigElem.addChild(
                XMLElement.init(name: WordEndElemIdentifier, stringValue: value))
        }

        if let value = self.style?.face?.description {
            trigElem.addAttribute(name: TriggerAttribIdentifier.face.rawValue, stringValue: value)
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

        if let value = audioCueDict[self.audioCue] {
            trigElem.addAttribute(name: TriggerAttribIdentifier.audio.rawValue, stringValue: value)
        }

        if let value = self.voice {
            trigElem.addAttribute(name: TriggerAttribIdentifier.voice.rawValue, stringValue: value)
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
        (.useFore, "useFore"), // TODO: obsolete this
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
        // intentially skipping "useFore"
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
