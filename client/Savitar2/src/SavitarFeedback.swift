//
//  SavitarFeedback.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Email feedback flow and one-time alpha announcement (Story 15).
enum SavitarFeedback {
    static let hasSeenAnnouncementKey = "SavitarHasSeenAlphaFeedbackAnnouncement"

    private static let defaultSupportEmail = "jay@heynow.com"

    static var supportEmail: String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SavitarFeedbackEmail") as? String else {
            return defaultSupportEmail
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultSupportEmail : trimmed
    }

    static func presentAlphaAnnouncementIfNeeded() {
        guard !isRunningTests else { return }
        guard !SavitarUserDefaults.standard.bool(forKey: hasSeenAnnouncementKey) else { return }

        let alert = NSAlert()
        alert.messageText = "Welcome to the Savitar 2 alpha"
        alert.informativeText = alphaAnnouncementText
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

    private static let alphaAnnouncementText = """
    Savitar 2 is in an alpha test — early software we share with a small group while we finish \
    the last Savitar 1 features and polish rough edges before a wider beta.

    What is an alpha test?

    You are using Savitar while we are still building it. Features may be missing, behave oddly, \
    or change between updates. That is expected. Your job is to play for real and tell us what \
    works and what does not.

    We are close to Savitar 1 feature complete in version 2.0. After that milestone ships, we \
    will add command aliases and other Savitar 2-only features.

    Please send any and all feedback — bugs, confusing UI, missing Savitar 1 behavior, or ideas. \
    Use Help → Send Feedback… (no GitHub account needed). Try Help → Savitar Help (⌘?) first if \
    you are not sure where a setting lives.
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
