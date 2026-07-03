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

    @IBAction func toggleMuteSoundAction(_ sender: NSMenuItem) {
        muteSound = sender.state == .on
    }

    @IBAction func toggleMuteSpeakingAction(_ sender: NSMenuItem) {
        muteSpeaking = sender.state == .on
    }

    @IBAction func flushSpeachAction(_: Any) {
        AppContext.shared.speakerMan.flushSpeech()
    }

    @IBAction func speakSelectedTextAction(_: Any) {
        speakSelectedText()
    }

    private func speakSelectedText() {
        let window = NSApp.keyWindow
        let voice = AppContext.shared.speakerMan.resolvedContinuousSpeechVoiceName()
        let speak: (String) -> Void = { text in
            AppContext.shared.speakerMan.speak(text: text, voiceName: voice)
        }

        if let output = outputView(for: window), isResponder(in: output) {
            output.selectedPlainText { text in
                guard let text else { return }
                DispatchQueue.main.async { speak(text) }
            }
            return
        }

        if let text = selectedInputText(from: window) {
            speak(text)
            return
        }

        outputView(for: window)?.selectedPlainText { text in
            guard let text else { return }
            DispatchQueue.main.async { speak(text) }
        }
    }

    private func canSpeakSelectedText() -> Bool {
        let window = NSApp.keyWindow
        if selectedInputText(from: window) != nil { return true }
        if let output = outputView(for: window), isResponder(in: output) { return true }
        return false
    }

    private func selectedInputText(from window: NSWindow?) -> String? {
        guard let textView = window?.firstResponder as? NSTextView else { return nil }
        let range = textView.selectedRange()
        guard range.length > 0 else { return nil }
        return (textView.string as NSString).substring(with: range)
    }

    private func sessionViewController(for window: NSWindow?) -> SessionViewController? {
        guard let wc = window?.windowController as? WindowController else { return nil }
        return wc.contentViewController as? SessionViewController
    }

    private func outputView(for window: NSWindow?) -> OutputView? {
        sessionViewController(for: window)?.outputViewController?.outputView
    }

    private func isResponder(in view: NSView) -> Bool {
        guard var responder = view.window?.firstResponder as? NSView else { return false }
        while true {
            if responder === view { return true }
            guard let superview = responder.superview else { break }
            responder = superview
        }
        return false
    }

    @IBAction func showAppPrefsAction(_: Any) {
        AppContext.shared.showAppPrefsWindow()
    }

    @IBAction func showContinuousSpeechPrefsAction(_: Any) {
        AppContext.shared.showContinuousSpeechPrefsWindow()
    }

    @IBAction func showANSIColorsAction(_: Any) {
        AppContext.shared.showAppPrefsWindow(selecting: .colors)
    }

    @IBAction func showEventsWindowAction(_: Any) {
        AppContext.shared.showUniversalEventsWindow()
    }

    @IBAction func showWorldPickerAction(_: Any) {
        AppContext.shared.showWorldPicker()
    }

    @IBAction func newTextDocumentAction(_: Any) {
        do {
            let document = try NSDocumentController.shared.makeUntitledDocument(
                ofType: PlainTextDocument.fileType
            )
            NSDocumentController.shared.addDocument(document)
            document.makeWindowControllers()
        } catch {
            NSApp.presentError(error)
        }
    }

    @IBAction func performFindAction(_ sender: Any) {
        guard let menuItem = sender as? NSMenuItem else { return }
        let window = NSApp.keyWindow

        if let textView = window?.firstResponder as? NSTextView,
           let inputView = sessionViewController(for: window)?.inputViewController?.textView,
           textView === inputView {
            textView.performFindPanelAction(sender)
            return
        }

        guard let outputVC = sessionViewController(for: window)?.outputViewController else { return }
        outputVC.performFindPanelAction(menuItem)
    }

    func newState(state _: AppPreferencesState) {
        willChangeValue(forKey: "muteSound")
        didChangeValue(forKey: "muteSound")
        willChangeValue(forKey: "muteSpeaking")
        didChangeValue(forKey: "muteSpeaking")
    }
}

extension AppDelegate: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(speakSelectedTextAction(_:)):
            return canSpeakSelectedText()
        case #selector(flushSpeachAction(_:)):
            return AppContext.shared.speakerMan.isSpeaking()
        case #selector(toggleMuteSoundAction(_:)), #selector(toggleMuteSpeakingAction(_:)):
            return true
        case #selector(performFindAction(_:)):
            return canPerformFind(in: NSApp.keyWindow)
        default:
            return true
        }
    }

    private func canPerformFind(in window: NSWindow?) -> Bool {
        guard window != nil else { return false }
        if sessionViewController(for: window) != nil { return true }
        if window?.firstResponder is NSTextView { return true }
        return false
    }
}
