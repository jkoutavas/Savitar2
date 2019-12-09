//
//  AppDelegate.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        MSAppCenter.start("773fa530-0ff3-4a5a-984f-32fdf7b29baa", withServices: [
          MSAnalytics.self,
          MSCrashes.self
        ])

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

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
}
