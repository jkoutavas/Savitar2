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
    @objc dynamic var muteSound: Bool {
        get { AppContext.shared.prefs.flags.contains(.muteSound) }
        set {
            if newValue == false {
                AppContext.shared.prefs.flags.remove(.muteSound)
            } else {
                AppContext.shared.prefs.flags.insert(.muteSound)
            }
        }
    }

    @objc dynamic var muteSpeaking: Bool {
        get { AppContext.shared.prefs.flags.contains(.muteSpeaking) }
        set {
            if newValue == false {
                AppContext.shared.prefs.flags.remove(.muteSpeaking)
            } else {
                AppContext.shared.prefs.flags.insert(.muteSpeaking)
            }
        }
    }

    override init() {
        super.init()
        AppContext.shared.load()
    }

    func applicationDidFinishLaunching(_: Notification) {
        if isRunningTests {
            return
        }

         AppCenter.start(withAppSecret: "773fa530-0ff3-4a5a-984f-32fdf7b29baa", services: [
            Analytics.self, Crashes.self
         ])

        if AppContext.shared.prefs.flags.contains(.startupPicker) {
            showWorldPickerAction(self)
        }

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

    @IBAction func flushSpeachAction(_: Any) {
        AppContext.shared.speakerMan.flushSpeech()
    }

    @IBAction func showAppPrefsAction(_: Any) {
        AppContext.shared.showAppPrefsWindow()
    }

    @IBAction func showContinuousSpeechPrefsAction(_: Any) {
        AppContext.shared.showContinuousSpeechPrefsWindow()
    }

    @IBAction func showEventsWindowAction(_: Any) {
        AppContext.shared.showUniversalEventsWindow()
    }

    @IBAction func showWorldPickerAction(_: Any) {
        AppContext.shared.showWorldPicker()
    }
}
