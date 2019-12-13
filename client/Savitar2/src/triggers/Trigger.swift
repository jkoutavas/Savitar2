//
//  Trigger.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/1/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa

enum TrigType {
    case Unknown
    case Input
    case Output
    case Both
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

class Trigger: NSObject, SavitarXMLProtocol {
    // default settings
    var name: String = "<new trigger>"
    var type: TrigType = .Output
    var flags: TrigFlags = .exact

    // optional settings
    var reply: String?
    var style: TrigTextStyle?
    var substitution: String?
    var wordEnding: String?

    init(name: String,
         type: TrigType? = nil,
         flags: TrigFlags? = nil,
         reply: String? = nil,
         style: TrigTextStyle? = nil,
         substitution: String? = nil,
         wordEnding: String? = nil) {

        self.name = name

        if let t = type {
            self.type = t
        }
        if let f = flags {
            self.flags = f
        }
        self.reply = reply
        self.style = style
        self.substitution = substitution
        self.wordEnding = wordEnding
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

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    let TriggerElemIdentifier = "TRIGGER"
    let ReplyElemIdentifier = "REPLY"
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

    let typeLabels: [String: TrigType] = [
        "unknown": .Unknown,
        "input": .Input,
        "output": .Output,
        "both": .Both
    ]

    var currentString = ""
    var storingCharacters = false
    func parseXML(from data: Data) throws {

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        switch elementName {
        case TriggerElemIdentifier:
            for attribute in attributeDict {
                switch attribute.key {
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
                case TriggerAttribIdentifier.type.rawValue:
                    if let type = typeLabels[attribute.value] {
                        self.type = type
                    } else {
                        self.type = .Unknown
                    }
                default:
                    print("skipping trigger attribute \(attribute.key)")
                }
            }
        case ReplyElemIdentifier, SubsitutionElemIdentifier, SubstitutionElemIdentifier, WordEndElemIdentifier:
            currentString = ""
            storingCharacters = true
        default:
            // TODO: pass a logging object into Trigger
            print("skipping XML element \(elementName) start")
        }
    }
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        switch elementName {
        case ReplyElemIdentifier:
             self.reply = currentString
        case SubsitutionElemIdentifier, SubstitutionElemIdentifier:
            self.substitution = currentString
        case WordEndElemIdentifier:
            self.wordEnding = currentString
        default:
            // TODO: pass a logging object into Trigger
            print("skipping XML element \(elementName) end")
        }
        storingCharacters = false
    }

    func toXMLElement() throws -> XMLElement {
        let trigElem = XMLElement(name: TriggerElemIdentifier)

        // TODO: need to do XML escaping here?
        guard let name = XMLNode.attribute(withName: TriggerAttribIdentifier.name.rawValue,
                                           stringValue: "\(name)") as? XMLNode else {
            throw NSError()
        }
        trigElem.addAttribute(name)

//        logger.info("XML data representation \(String(worldElem.xmlString))")
        return trigElem
    }
}

extension TrigFlags: StrOptionSet {
    // TODO: I wonder if there's a DRY-er way to do these
    static var labels: [Label] { return [
        (.exact, "exact"),
        (.toEndOfWord, "matchToEndOfWord"),
        (.wholeLine, "wholeLine"),
        (.disabled, "disabled"),
        (.useFore, "useFore"), // TODO: obsolete this
        (.gag, "gag"),
        (.startsWith, "startsWith"),
        (.echoReply, "echoReply"),
        (.caseSensitive, "caseSensitive"),
        (.dontUseStyle, "dontUseStyle"),
        (.useSubstitution, "useSubstitution"), // Note: new label correct spelling for v2
        (.useRegex, "useRegex")
    ]}
    static var labelDict: [String: Self] { return [
        "exact": .exact,
        "matchToEndOfWord": .toEndOfWord,
        "wholeLine": .wholeLine,
        "disabled": .disabled,
        // intentially skipping "useFore"
        "gag": .gag,
        "startsWith": .startsWith,
        "echoReply": .echoReply,
        "caseSensitive": .caseSensitive,
        "dontUseStyle": .dontUseStyle,
        "useSubstitution": .useSubstitution, // Note: new v2.0 correctly spelled label
        "useSubsitution": .useSubstitution, // Note: old (misspelled) v1.0 label
        "useRegex": .useRegex
    ]}
}
