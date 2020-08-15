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

    @IBAction func showEventsWindowAction(_ sender: Any) {
        let bundle = Bundle(for: Self.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? NSWindowController else {
            return
        }
        guard let myWindow = controller.window else {
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        let vc = NSWindowController(window: myWindow)

        if let splitViewController = myWindow.contentViewController as? EventsSplitViewController {
            splitViewController.store = globalStore
            vc.showWindow(self)
        }
        myWindow.makeKeyAndOrderFront(self)
    }
}
