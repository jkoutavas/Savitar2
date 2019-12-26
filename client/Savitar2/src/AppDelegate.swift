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

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
     }

    func applicationWillTerminate(_ aNotification: Notification) {
        if isRunningTests {
            return
        }

        do {
            try AppContext.save()
        } catch {}
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
}
