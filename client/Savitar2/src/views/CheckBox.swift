//
//  CheckBox.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class CheckBox: NSButton {
    var checked: Bool {
        get { return state == .on }
        set { state = newValue ? .on : .off }
    }
}
