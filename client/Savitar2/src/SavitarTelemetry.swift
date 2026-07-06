//
//  SavitarTelemetry.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import TelemetryDeck

/// Privacy-first install and usage analytics via TelemetryDeck (Story 14).
enum SavitarTelemetry {
    private static let hasLaunchedBeforeKey = "SavitarHasLaunchedBefore"

    static func initializeIfConfigured() {
        guard !isRunningTests else { return }

        guard let appID = configuredAppID else { return }

        let config = TelemetryDeck.Config(appID: appID)
        #if DEBUG
        config.testMode = true
        #endif
        TelemetryDeck.initialize(config: config)

        let parameters = versionParameters(isReleaseBuild: true)
        TelemetryDeck.signal("Savitar.launched", parameters: parameters)

        if !UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey) {
            TelemetryDeck.signal("Savitar.firstLaunch", parameters: parameters)
            UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        }
    }

    private static var configuredAppID: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "TelemetryDeckAppID") as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func versionParameters(isReleaseBuild: Bool) -> [String: String] {
        let bundle = Bundle.main
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersionString

        return [
            "appVersion": appVersion,
            "buildNumber": buildNumber,
            "macOSVersion": macOSVersion,
            "isReleaseBuild": isReleaseBuild ? "true" : "false",
        ]
    }
}
