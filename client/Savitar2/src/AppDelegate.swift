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
import ReSwift

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StoreSubscriber {
    @objc dynamic var muteSound: Bool {
        get { AppContext.shared.prefs.flags.contains(.muteSound) }
        set { AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSound, enabled: newValue)) }
    }

    @objc dynamic var muteSpeaking: Bool {
        get { AppContext.shared.prefs.flags.contains(.muteSpeaking) }
        set { AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSpeaking, enabled: newValue)) }
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

        AppContext.shared.restoreSavedWindows()

        AppContext.shared.appPrefsStore.subscribe(self)

        if AppContext.shared.prefs.flags.contains(.startupPicker) {
            showWorldPickerAction(self)
        }

        if AppContext.shared.prefs.flags.contains(.startupEventsWindow) {
            showEventsWindowAction(self)
        }
    }

    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        if isRunningTests {
            return .terminateNow
        }

        AppContext.shared.prepareForTermination()
        return .terminateNow
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

    func newState(state _: AppPreferencesState) {
        willChangeValue(forKey: "muteSound")
        didChangeValue(forKey: "muteSound")
        willChangeValue(forKey: "muteSpeaking")
        didChangeValue(forKey: "muteSpeaking")
    }
}
