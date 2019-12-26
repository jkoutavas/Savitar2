//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa

struct AppContext {
    static var prefs = AppPreferences()
    static var triggerMan = TriggerMan()

    static func load() throws {
        try prefs.load()

        // TODO: load these from a test world document

        // gag tests
        triggerMan.add(Trigger(name: "hide", flags: [.caseSensitive, .exact, .gag]))
        triggerMan.add(Trigger(name: "wholeline", flags: [.wholeLine, .gag]))

        // substitution tests
        triggerMan.add(Trigger(name: "bang*", flags: [.useRegex, .useSubstitution], substitution: "HEYNOW"))

        // styling tests
        triggerMan.add(Trigger(name: "ell", flags: [.caseSensitive, .exact],
             style: TrigTextStyle(face: .bold)))

        triggerMan.add(Trigger(name: "test", flags: .exact,
             style: TrigTextStyle(face: .blink)))

        triggerMan.add(Trigger(name: "TO END", flags: .wholeLine,
             style: TrigTextStyle(face: .underline)))

        triggerMan.add(Trigger(name: "boom*", flags: [.caseSensitive, .useRegex],
             style: TrigTextStyle(face: .italic)))

        triggerMan.add(Trigger(name: "combo", flags: [.caseSensitive, .useRegex],
             style: TrigTextStyle(face: [.italic, .underline])))

        triggerMan.add(Trigger(name: "inverse",
             style: TrigTextStyle(face: .inverse)))

        triggerMan.add(Trigger(name: "purple",
             style: TrigTextStyle(foreColor: NSColor.purple)))

        triggerMan.add(Trigger(name: "warning", flags: .wholeLine,
             style: TrigTextStyle(face: .underline, backColor: NSColor.red)))
    }

    static func save() throws {
        try prefs.save()
    }
}
