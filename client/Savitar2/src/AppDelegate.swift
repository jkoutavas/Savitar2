//
//  AppDelegate.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // TODO: load these from v1 or v2 settings
        AppContext.triggerMan.add(Trigger(name: "ell", flags: [.caseSensitive, .exact]))
        AppContext.triggerMan.add(Trigger(name: "test", flags: .exact))
        AppContext.triggerMan.add(Trigger(name: "hide", flags: [.caseSensitive, .exact, .gag]))
        AppContext.triggerMan.add(Trigger(name: "line", flags: [.wholeLine, .gag]))
        AppContext.triggerMan.add(Trigger(name: "TO END", flags: .wholeLine))
        AppContext.triggerMan.add(Trigger(name: "bang*", flags: [.useRegex, .useSubstitution], substitution: "HEYNOW"))
        AppContext.triggerMan.add(Trigger(name: "boom*", flags: [.caseSensitive, .useRegex]))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
}
