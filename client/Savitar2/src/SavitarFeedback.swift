//
//  SavitarFeedback.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Email feedback flow and one-time beta announcement (Story 15).
enum SavitarFeedback {
    static let hasSeenAnnouncementKey = "SavitarHasSeenBetaFeedbackAnnouncement"

    private static let defaultSupportEmail = "jay@heynow.com"

    static var supportEmail: String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SavitarFeedbackEmail") as? String else {
            return defaultSupportEmail
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultSupportEmail : trimmed
    }

    static func presentBetaAnnouncementIfNeeded() {
        guard !isRunningTests else { return }
        guard !SavitarUserDefaults.standard.bool(forKey: hasSeenAnnouncementKey) else { return }

        let alert = NSAlert()
        alert.messageText = "Welcome to the Savitar 2 beta"
        alert.informativeText = betaAnnouncementText
        alert.alertStyle = .informational

        alert.addButton(withTitle: "Open Savitar Help")
        alert.addButton(withTitle: "Send Feedback…")
        let gotIt = alert.addButton(withTitle: "Got It")
        gotIt.keyEquivalent = "\r"

        let response = alert.runModal()
        SavitarUserDefaults.standard.set(true, forKey: hasSeenAnnouncementKey)

        switch response {
        case .alertFirstButtonReturn:
            SavitarHelp.show()
        case .alertSecondButtonReturn:
            sendFeedback()
        default:
            break
        }
    }

    static func sendFeedback() {
        guard !isRunningTests else { return }

        guard let url = makeMailtoURL() else {
            presentMailUnavailableAlert()
            return
        }

        if NSWorkspace.shared.open(url) {
            return
        }
        presentMailUnavailableAlert()
    }

    static func diagnosticsText() -> String {
        let bundle = Bundle.main
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersionString

        return """
        Savitar version: \(appVersion)
        Build: \(buildNumber)
        macOS: \(macOSVersion)
        Support email: \(supportEmail)
        """
    }

    static func feedbackEmailBodyTemplate() -> String {
        """
        — Please fill in below —

        What I was trying to do:


        What happened:


        Bug or feature request?


        — Diagnostics (please leave this block) —
        \(diagnosticsText())
        """
    }

    static func makeMailtoURL() -> URL? {
        let bundle = Bundle.main
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let subject = "Savitar 2 feedback (\(appVersion) build \(buildNumber))"
        let body = feedbackEmailBodyTemplate()

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }

    private static let betaAnnouncementText = """
    Savitar 2 is ready for a wider beta — software we share while we polish rough edges and \
    prepare the 2.0 release.

    Whether you used Savitar 1 for years or are trying Savitar (and MUDs) for the first time, \
    welcome. Returning players get Savitar 1.6.3 feature parity; newcomers get in-app help to \
    get connected and playing.

    What is a beta test?

    You are using Savitar while we finish validation with a broader audience. Things may still \
    change, and you may hit bugs or rough edges. That is expected. Play for real and tell us \
    what works and what does not.

    If you used Savitar 1: compare behavior to what you remember — triggers, macros, local \
    commands, and world settings should feel familiar. If something is missing or different, \
    we want to know.

    If Savitar is new to you: open the World Picker, connect to a world, and type ##help in \
    the input line. Help → Savitar Help (⌘?) walks through sessions, triggers, and settings \
    at your own pace.

    Command aliases and other Savitar 2-only features are planned after the 2.0 milestone ships.

    Please send any and all feedback — bugs, confusing UI, missing Savitar 1 behavior, or ideas. \
    Use Help → Send Feedback… (no GitHub account needed).
    """

    private static func presentMailUnavailableAlert() {
        let alert = NSAlert()
        alert.messageText = "Unable to open Mail"
        alert.informativeText = """
        Your Mac does not have a default email app configured, or Mail could not be opened.

        Send your feedback to \(supportEmail). Use Copy Diagnostics to paste version information into your message.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Copy Diagnostics to Clipboard")
        alert.addButton(withTitle: "OK")

        if alert.runModal() == .alertFirstButtonReturn {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(feedbackEmailBodyTemplate(), forType: .string)
        }
    }
}
