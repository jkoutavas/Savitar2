//
//  SessionKeepAlive.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//
//  Savitar 1.x origin: CTextConnectionMac::SpendTime / SendKeepAlive
//  After N minutes with no outbound traffic, send a single null byte (not IAC NOP).

import Foundation

enum SessionKeepAlive {
    /// Raw TCP null byte — same payload Savitar 1 wrote via `SendKeepAlive`.
    static let nullBytePayload = Data([0])

    /// How often the session polls whether a keepalive is due.
    static let pollIntervalSeconds: TimeInterval = 15

    /// `true` when `keepAliveMins` is enabled and outbound silence has reached the threshold.
    static func shouldSend(keepAliveMins: Int, lastOutbound: Date, now: Date = Date()) -> Bool {
        guard keepAliveMins > 0 else { return false }
        return now.timeIntervalSince(lastOutbound) >= Double(keepAliveMins) * 60.0
    }
}
