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

        MSAppCenter.start("773fa530-0ff3-4a5a-984f-32fdf7b29baa", withServices: [
            MSAnalytics.self,
            MSCrashes.self
        ])

        do {
            try AppContext.load()
        } catch {}

        if AppContext.prefs.flags.contains(.startupEventsWindow) {
            showEventsWindowAction(self)
        }
    }

    func applicationWillTerminate(_: Notification) {
        if isRunningTests {
            return
        }
        AppContext.isTerminating = true
        AppContext.save()
    }

    func applicationOpenUntitledFile(_: NSApplication) -> Bool {
        return true
    }

    @IBAction func showEventsWindowAction(_: Any) {
        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? EventsWindowController else {
            return
        }
        guard let myWindow = controller.window else {
            return
        }

        if let splitViewController = myWindow.contentViewController as? EventsSplitViewController {
            splitViewController.store = globalStore
            controller.showWindow(self)
            AppContext.prefs.flags.insert(.startupEventsWindow)
            AppContext.save()
        }
    }
}
