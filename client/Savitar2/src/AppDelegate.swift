//
//  AppDelegate.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Cocoa

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_: Notification) {
        if isRunningTests {
            return
        }

// TODO: consider re-enabling this
/*
        MSAppCenter.start("773fa530-0ff3-4a5a-984f-32fdf7b29baa", withServices: [
            MSAnalytics.self,
            MSCrashes.self
        ])
*/
        do {
            try AppContext.shared.load()
        } catch {}

        if AppContext.shared.prefs.flags.contains(.startupEventsWindow) {
            showEventsWindowAction(self)
        }
    }

    func applicationOpenUntitledFile(_: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_: Notification) {
        if isRunningTests {
            return
        }
        AppContext.shared.appIsTerminating()
    }

    @IBAction func showEventsWindowAction(_: Any) {
        AppContext.shared.showUniversalEventsWindow()
    }

    @IBAction func showWorldPickerAction(_: Any) {
        AppContext.shared.showWorldPicker()
    }
}
