//
//  SavitarUserDefaults.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

/// App-owned UserDefaults keys (window positions, one-shot flags, etc.).
/// During unit tests (hosted in Savitar.app) uses an isolated suite so `xcodebuild test`
/// does not read or write the developer install's live preferences domain.
enum SavitarUserDefaults {
    private static let testSuiteName = "com.heynow.Savitar2Tests"

    static var standard: UserDefaults {
        if isRunningTests {
            return UserDefaults(suiteName: testSuiteName)!
        }
        return .standard
    }
}
