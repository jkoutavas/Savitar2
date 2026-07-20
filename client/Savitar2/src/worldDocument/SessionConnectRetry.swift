//
//  SessionConnectRetry.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//
//  Savitar 1.x origin: CTextConnectionMac countdown / GetRetrySecs()
//  When Retry Seconds > 0, auto-reconnect after an unexpected disconnect.

import Foundation

enum SessionConnectRetry {
    /// `true` when World Settings → Starting → Retry Seconds enables auto-reconnect.
    /// `0` means off (same as Savitar 1 — no countdown).
    static func shouldAutoRetry(retrySecs: Int) -> Bool {
        retrySecs > 0
    }

    /// Delay before the next connect attempt.
    static func delaySeconds(retrySecs: Int) -> TimeInterval {
        TimeInterval(max(retrySecs, 0))
    }
}
