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

enum AppPreferencesError: Error {
    case missingStartupPreferences
}

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
    /// v1 Events outline disclosure (Universal / per-world groups). Import-only in v2 — no UI uses these flags.
    static let trigsClosed = PrefsFlags(rawValue: 1 << 8)
    static let varsClosed = PrefsFlags(rawValue: 1 << 9)
    static let debug = PrefsFlags(rawValue: 1 << 10)
    static let monoFontsOnly = PrefsFlags(rawValue: 1 << 11)
    static let defaultWordWrap = PrefsFlags(rawValue: 1 << 12)
    static let dontWarnPicker = PrefsFlags(rawValue: 1 << 13)
    static let startupEventsWindow = PrefsFlags(rawValue: 1 << 14)
}

class AppPreferences: SavitarXMLProtocol {
    let v1PrefsPath = "~/Library/Preferences/Savitar 2.0 Prefs"
    let v2PrefsPath = "~/Library/Preferences/Savitar2 Prefs"

    let prevPrefsVersion = 140
    let latestPrefsVersion = 200
    var version = 0

    var continuousSpeechEnabled = false
    var continuousSpeechRate = 10 // 5..20, whereas 10 is normal, 5 is 1/2 speed and 20 is 2x speed
    var continuousSpeechVoice = ""
    var flags: PrefsFlags = [.startupPicker, .useKeypad]
    var lastUpdateSecs = 0
    var updatingEnabled = true
    var appearanceMode: AppAppearanceMode = .system

    // TODO: this is deprecating
    var colorMan = ColorMan()

    var openSessions: [SavedOpenSession] = []
    var clickerMan = ClickerMan()

    init() {
        version = latestPrefsVersion
    }

    func load() {
        if isRunningTests {
            try? loadFactoryDefaults()
            return
        }

        // An interesting bit of Savitar history trivia... Savitar v1.x named its prefs file as "2.0"
        // during a significant change in the content of the preferences during minor releases, and I was
        // anticipating bumping Savitar's major version, but that didn't come to pass.

        var loaded = false

        // Try to load v2 preferences, if any.
        do {
            // Note: sandboxing must be turned off in order for the tilde expansion to occur in the right place
            let xmlStr = try String(contentsOfFile: NSString(string: v2PrefsPath).expandingTildeInPath)
            let xml = try XML.parse(xmlStr)
            try parse(xml: xml[PreferencesElemIdentifier])
            loaded = true
        } catch {
            // It's okay if loading v2 prefs failed. It simply means Savitar v2 is not installed, or the v2 preferences
            // are corrupt.
        }

        if loaded == true {
            return
        }

        // Try to load v1 preferences, if any.
        do {
            // Note: sandboxing must be turned off in order for the tilde expansion to occur in the right place
            var xmlStr = try String(contentsOfFile: NSString(string: v1PrefsPath).expandingTildeInPath)

            // v1 Savitar macros use the "&ret;" custom entity to separate lines of text.
            // XMLParser has a known bug with handling custom entities (of which SwiftyXMLParser is based)
            // See: https://stackoverflow.com/questions/44680734/parsing-xml-with-entities-in-swift-with-xmlparser
            // Here we're simply replace it with a \n to indicate a line feed
            xmlStr = xmlStr.replacingOccurrences(of: "&ret;", with: "\n")

            let xml = try XML.parse(xmlStr)
            try parse(xml: xml[PreferencesElemIdentifier])
            loaded = true
        } catch {
            // It's okay if loading v1 prefs failed. It simply means Savitar v1 is not installed, or the v1 preferences
            // are corrupt.
        }

        if loaded == true {
            return
        }

        try? loadFactoryDefaults()
    }

    /// Reloads bundled `StartupPreferences.xml` — used for first launch and factory reset.
    func loadFactoryDefaults() throws {
        guard let filepath = Bundle.main.path(forResource: "StartupPreferences", ofType: "xml") else {
            throw AppPreferencesError.missingStartupPreferences
        }
        let xmlStr = try String(contentsOfFile: filepath).trimmingCharacters(in: .whitespacesAndNewlines)
        let xml = try XML.parse(xmlStr)
        try parse(xml: xml[PreferencesElemIdentifier])
    }

    func save() {
        guard !isRunningTests else { return }

        do {
            let xmlOutputStr = try toXMLElement().xmlString.prettyXMLFormat()

            // Note: sandboxing must be turned off in order for the tilde expansion to occur in the right place
            let filename = NSString(string: v2PrefsPath).expandingTildeInPath
            let fileURL = URL(fileURLWithPath: filename)
            try xmlOutputStr.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be
            // converted to the encoding
        }
    }

    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

    enum PrefsAttribIdentifier: String {
        case version = "VERSION"
        case flags = "FLAGS"
        case updatingEnabled = "UPDATING_ENABLED"
        case lastUpdateCheck = "LAST_UPDATE_CHECK"
        case continuousSpeechEnabled = "CONTINUOUS_SPEECH_ENABLED"
        case continuousSpeechRate = "CONTINUOUS_SPEECH_RATE"
        case continuousSpeechVoice = "CONTINUOUS_SPEECH_VOICE"
        case appAppearance = "APPAPPEARANCE"
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
            case PrefsAttribIdentifier.continuousSpeechVoice.rawValue:
                prefs.continuousSpeechVoice = attribute.value
            case PrefsAttribIdentifier.updatingEnabled.rawValue:
                prefs.updatingEnabled = attribute.value == "TRUE"
            case PrefsAttribIdentifier.appAppearance.rawValue:
                if let mode = AppAppearanceMode.from(xmlValue: attribute.value) {
                    prefs.appearanceMode = mode
                }
            default:
                print("skipping prefs attribute \(attribute.key)")
            }
        }

        let worldMan = WorldMan()
        try worldMan.parse(xml: xml)
        AppContext.shared.worldPickerStore.dispatch(SetWorldsAction(worlds: worldMan.get()))

        let triggerMan = TriggerMan()
        try triggerMan.parse(xml: xml)
        AppContext.shared.universalReactionsStore.dispatch(SetTriggersAction(triggers: triggerMan.get()))

        let macroMan = MacroMan()
        try macroMan.parse(xml: xml)
        AppContext.shared.universalReactionsStore.dispatch(SetMacrosAction(macros: macroMan.get()))

        try prefs.clickerMan.parse(xml: xml)

        try prefs.colorMan.parse(xml: xml)
        prefs.openSessions = WindowRestoration.parseOpenSessions(xml: xml)
    }

    func toXMLElement() throws -> XMLElement {
        let prefsElem = XMLElement(name: PreferencesElemIdentifier)

        version = latestPrefsVersion

        prefsElem.addAttribute(name: PrefsAttribIdentifier.version.rawValue,
                               stringValue: "\(version)")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.continuousSpeechEnabled.rawValue,
                               stringValue: continuousSpeechEnabled ? "TRUE" : "FALSE")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.continuousSpeechRate.rawValue,
                               stringValue: "\(continuousSpeechRate)")

        if continuousSpeechVoice.count > 0 {
            prefsElem.addAttribute(name: PrefsAttribIdentifier.continuousSpeechVoice.rawValue,
                                   stringValue: "\(continuousSpeechVoice)")
        }

        prefsElem.addAttribute(name: PrefsAttribIdentifier.flags.rawValue,
                               stringValue: flags.description)

        prefsElem.addAttribute(name: PrefsAttribIdentifier.lastUpdateCheck.rawValue,
                               stringValue: "\(lastUpdateSecs)")

        prefsElem.addAttribute(name: PrefsAttribIdentifier.updatingEnabled.rawValue,
                               stringValue: updatingEnabled ? "TRUE" : "FALSE")

        if appearanceMode != .system {
            prefsElem.addAttribute(name: PrefsAttribIdentifier.appAppearance.rawValue,
                                   stringValue: appearanceMode.xmlValue)
        }

        if let worlds = AppContext.shared.worldPickerStore.state?.worldList.items {
            let worldMan = WorldMan(worlds)
            let worldsElem = try worldMan.toXMLElement()
            if worldsElem.childCount > 0 {
                prefsElem.addChild(worldsElem)
            }
        }

        if let triggers = AppContext.shared.universalReactionsStore.state?.triggerList.items {
            let triggerMan = TriggerMan(triggers)
            let triggersElem = try triggerMan.toXMLElement()
            if triggersElem.childCount > 0 {
                prefsElem.addChild(triggersElem)
            }
        }

        if let macros = AppContext.shared.universalReactionsStore.state?.macroList.items {
            let macroMan = MacroMan(macros)
            let macrosElem = try macroMan.toXMLElement()
            if macrosElem.childCount > 0 {
                prefsElem.addChild(macrosElem)
            }
        }

        let aliasesElem = try clickerMan.toXMLElement()
        if aliasesElem.childCount > 0 {
            prefsElem.addChild(aliasesElem)
        }

        let colorsElem = try colorMan.toXMLElement()
        if colorsElem.childCount > 0 {
            prefsElem.addChild(colorsElem)
        }

        if let openSessionsElem = WindowRestoration.openSessionsElement(
            for: WindowRestoration.sessionsToPersist(storedSessions: openSessions)
        ) {
            prefsElem.addChild(openSessionsElem)
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
        (.dontWarnPicker, "dontWarnPicker"),
        (.startupEventsWindow, "startupEventsWindow")
    ] }
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
        "dontWarnPicker": .dontWarnPicker,
        "startupEventsWindow": .startupEventsWindow
    ] }
}
