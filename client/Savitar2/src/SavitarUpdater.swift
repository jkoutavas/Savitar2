//
//  SavitarUpdater.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import Sparkle

/// Sparkle 2 integration for Developer ID–signed updates.
final class SavitarUpdater: NSObject {
    static let shared = SavitarUpdater()

    /// HTTPS appcast served from the repo (updated by the release workflow on each tag).
    private static let feedURLString =
        "https://raw.githubusercontent.com/jkoutavas/Savitar2/master/client/appcast/appcast.xml"

    private var updaterController: SPUStandardUpdaterController?

    private override init() {
        super.init()
    }

    func startIfNeeded() {
        guard updaterController == nil else { return }
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        applyAutomaticUpdatePreference(AppContext.shared.prefs.updatingEnabled)
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    func applyAutomaticUpdatePreference(_ enabled: Bool) {
        updaterController?.updater.automaticallyChecksForUpdates = enabled
    }
}

extension SavitarUpdater: SPUUpdaterDelegate {
    func feedURLString(for _: SPUUpdater) -> String? {
        Self.feedURLString
    }
}
