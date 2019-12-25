//
//  AppPreferencess.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/18/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

let PreferencesElemIdentifier = "PREFERENCES"

struct PrefsFlags: OptionSet {
   let rawValue: Int

   static let commandEcho = PrefsFlags(rawValue: 1 << 0)
   static let startupPicker = PrefsFlags(rawValue: 1 << 1)
   static let muteSound = PrefsFlags(rawValue: 1 << 2)
   static let muteSpeaking = PrefsFlags(rawValue: 1 << 3)
   static let muteClicker = PrefsFlags(rawValue: 1 << 4)
   static let muteBell = PrefsFlags(rawValue: 1 << 5)
   static let startupClicker = PrefsFlags(rawValue: 1 << 6)
   static let useKeypad = PrefsFlags(rawValue: 1 << 7)
   static let trigsClosed = PrefsFlags(rawValue: 1 << 8)
   static let varsClosed = PrefsFlags(rawValue: 1 << 9)
   static let debug = PrefsFlags(rawValue: 1 << 10)
   static let monoFontsOnly = PrefsFlags(rawValue: 1 << 11)
   static let defaultWordWrap = PrefsFlags(rawValue: 1 << 12)
   static let dontWarnPicker = PrefsFlags(rawValue: 1 << 13)
}

class AppPreferences: SavitarXMLProtocol {
    let prevPrefsVersion = 140
    let latestPrefsVersion = 200
    var version = 0

    var continuousSpeechEnabled = false
    var continuousSpeechRate = 10
    var flags: PrefsFlags = [.startupPicker, .useKeypad]
    var lastUpdateSecs = 0
    var updatingEnabled = true

    var worldMan = WorldMan()
    var triggerMan = TriggerMan()
    var variableMan = VariableMan()
    var colorMan = ColorMan()

    init() {
        self.version = latestPrefsVersion
    }

    func load() throws {
        let prefs = self

        // An interesting bit of Savitar history trivia... Savitar v1.x named its prefs file as "2.0"
        // during a significant change in the content of the preferences during minor releases, and I was
        // anticipating bumping Savitar's major version, but that didn't come to pass.

        // Try to load v2 preferences, if any.
        do {
            let v2PrefsPath = "~/Library/Preferences/Savitar2 Prefs"
            // Note: sandboxing must be turned off in order for the tilde expansion to occur in the right place
            let xmlStr = try String(contentsOfFile: NSString(string: v2PrefsPath).expandingTildeInPath)
            let xml = try XML.parse(xmlStr)
            try parse(xml: xml[PreferencesElemIdentifier])
        } catch {
            // It's okay if loading v2 prefs failed. It simply means Savitar v2 is not installed, or the v2 preferences
            // are corrupt.
        }

        // Try to load v1 preferences, if any.
        do {
            let v1PrefsPath = "~/Library/Preferences/Savitar 2.0 Prefs"
            // Note: sandboxing must be turned off in order for the tilde expansion to occur in the right place
            let xmlStr = try String(contentsOfFile: NSString(string: v1PrefsPath).expandingTildeInPath)
            let xml = try XML.parse(xmlStr)
            try parse(xml: xml[PreferencesElemIdentifier])
        } catch {
            // It's okay if loading v1 prefs failed. It simply means Savitar v1 is not installed, or the v1 preferences
            // are corrupt.
        }

        if prefs.version < prefs.latestPrefsVersion {
            // write-out v2 preferences
        }

        // TODO: load these from v1 or v2 settings

        // gag tests
        AppContext.triggerMan.add(Trigger(name: "hide", flags: [.caseSensitive, .exact, .gag]))
        AppContext.triggerMan.add(Trigger(name: "wholeline", flags: [.wholeLine, .gag]))

        // substitution tests
        AppContext.triggerMan.add(Trigger(name: "bang*", flags: [.useRegex, .useSubstitution], substitution: "HEYNOW"))

        // styling tests
        AppContext.triggerMan.add(Trigger(name: "ell", flags: [.caseSensitive, .exact],
             style: TrigTextStyle(face: .bold)))

        AppContext.triggerMan.add(Trigger(name: "test", flags: .exact,
             style: TrigTextStyle(face: .blink)))

        AppContext.triggerMan.add(Trigger(name: "TO END", flags: .wholeLine,
             style: TrigTextStyle(face: .underline)))

        AppContext.triggerMan.add(Trigger(name: "boom*", flags: [.caseSensitive, .useRegex],
             style: TrigTextStyle(face: .italic)))

        AppContext.triggerMan.add(Trigger(name: "combo", flags: [.caseSensitive, .useRegex],
             style: TrigTextStyle(face: [.italic, .underline])))

        AppContext.triggerMan.add(Trigger(name: "inverse",
             style: TrigTextStyle(face: .inverse)))

        AppContext.triggerMan.add(Trigger(name: "purple",
             style: TrigTextStyle(foreColor: NSColor.purple)))

        AppContext.triggerMan.add(Trigger(name: "warning", flags: .wholeLine,
             style: TrigTextStyle(face: .underline, backColor: NSColor.red)))
}

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    enum PrefsAttribIdentifier: String {
        case version = "VERSION"
        case flags = "FLAGS"
        case updatingEnabled = "UPDATING_ENABLED"
        case lastUpdateCheck = "LAST_UPDATE_CHECK"
        case continuousSpeechEnabled = "CONTINUOUS_SPEECH_ENABLED"
        case continuousSpeechRate = "CONTINUOUS_SPEECH_RATE"
    }

    func parse(xml: XML.Accessor) throws {
        let prefs = self
        prefs.version = prefs.prevPrefsVersion // start with the assumption that v1 prefs XML is being parsed
        for attribute in xml.attributes {
            switch attribute.key {
            case PrefsAttribIdentifier.version.rawValue:
                if let v = Int(attribute.value) {
                    prefs.version = v
                }
            case PrefsAttribIdentifier.flags.rawValue:
                if let raw = Int(attribute.value) {
                    // if flags come back as an int, we know we're parsing v1 prefs
                    prefs.flags = PrefsFlags(rawValue: raw)
                } else {
                    prefs.flags = PrefsFlags.from(string: attribute.value)
                }
            case PrefsAttribIdentifier.lastUpdateCheck.rawValue:
                if let v = Int(attribute.value) {
                    prefs.lastUpdateSecs = v
                }
            case PrefsAttribIdentifier.continuousSpeechEnabled.rawValue:
                prefs.continuousSpeechEnabled = attribute.value == "TRUE"
            case PrefsAttribIdentifier.continuousSpeechRate.rawValue:
                if let v = Int(attribute.value) {
                    prefs.continuousSpeechRate = v
                }
            case PrefsAttribIdentifier.updatingEnabled.rawValue:
                prefs.updatingEnabled = attribute.value == "TRUE"
            default:
                print("skipping prefs attribute \(attribute.key)")
            }
        }

        try prefs.worldMan.parse(xml: xml)
        try prefs.triggerMan.parse(xml: xml)
        try prefs.variableMan.parse(xml: xml)
        try prefs.colorMan.parse(xml: xml)
    }

    func toXMLElement() throws -> XMLElement {
        let prefsElem = XMLElement(name: PreferencesElemIdentifier)

        prefsElem.addAttribute(name: PrefsAttribIdentifier.version.rawValue,
            stringValue: "\(version)")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.continuousSpeechEnabled.rawValue,
            stringValue: continuousSpeechEnabled ? "TRUE" : "FALSE")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.continuousSpeechRate.rawValue,
            stringValue: "\(continuousSpeechRate)")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.flags.rawValue,
            stringValue: flags.description)

        prefsElem.addAttribute(name: PrefsAttribIdentifier.lastUpdateCheck.rawValue,
            stringValue: "\(lastUpdateSecs)")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.updatingEnabled.rawValue,
            stringValue: updatingEnabled ? "TRUE" : "FALSE")

        let worldsElem = try worldMan.toXMLElement()
        if worldsElem.childCount > 0 {
            prefsElem.addChild(worldsElem)
        }

        let triggersElem = try triggerMan.toXMLElement()
        if triggersElem.childCount > 0 {
            prefsElem.addChild(triggersElem)
        }

        let variablesElem = try variableMan.toXMLElement()
        if variablesElem.childCount > 0 {
            prefsElem.addChild(variablesElem)
        }

        let colorsElem = try colorMan.toXMLElement()
        if colorsElem.childCount > 0 {
            prefsElem.addChild(colorsElem)
        }

         return prefsElem
    }
}

extension PrefsFlags: StrOptionSet {
    // TODO: I wonder if there's a DRY-er way to do these
    static var labels: [Label] { return [
        (.commandEcho, "commandEcho"),
        (.startupPicker, "startupPicker"),
        (.muteSound, "muteSound"),
        (.muteSpeaking, "muteSpeaking"),
        (.muteClicker, "muteClicker"),
        (.muteBell, "muteBell"),
        (.startupClicker, "startupClicker"),
        (.useKeypad, "useKeypad"),
        (.trigsClosed, "trigsClosed"),
        (.varsClosed, "varsClosed"),
        (.debug, "debug"),
        (.monoFontsOnly, "monoFontsOnly"),
        (.defaultWordWrap, "defaultWordWrap"),
        (.dontWarnPicker, "dontWarnPicker")
    ]}
    static var labelDict: [String: Self] { return [
        "commandEcho": .commandEcho,
        "startupPicker": .startupPicker,
        "muteSound": .muteSound,
        "muteSpeaking": .muteSpeaking,
        "muteClicker": .muteClicker,
        "muteBell": .muteBell,
        "startupClicker": .startupClicker,
        "useKeypad": .useKeypad,
        "trigsClosed": .trigsClosed,
        "varsClosed": .varsClosed,
        "debug": .debug,
        "monoFontsOnly": .monoFontsOnly,
        "defaultWordWrap": .defaultWordWrap,
        "dontWarnPicker": .dontWarnPicker
    ]}
}
