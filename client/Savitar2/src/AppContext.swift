//
//  AppContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

struct AppContext {
    static var prefs = AppPreferences()
    static var triggerMan = TriggerMan()

    static func load() throws {
        try prefs.load()
    }
}
