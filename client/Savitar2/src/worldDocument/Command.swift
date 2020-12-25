//
//  Command.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/30/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

struct CmdFlags: OptionSet {
    let rawValue: Int

    static let dontProcess = CmdFlags(rawValue: 1 << 0) // don't do macro expansion
    static let suppressEcho = CmdFlags(rawValue: 1 << 1) // suppress echo to output even if world echoing is enabled
    static let forceEcho = CmdFlags(rawValue: 1 << 2) // force echo of output even if world echoing is disabled
    static let dontPostFix = CmdFlags(rawValue: 1 << 3) // don't attach postfix
    static let immediate = CmdFlags(rawValue: 1 << 4) // send this one immediately
    static let isScripted = CmdFlags(rawValue: 1 << 5) // this command is coming from a script (not hand entered)
    static let append = CmdFlags(rawValue: 1 << 6) // Append this to the input pane
}

struct Command: Equatable {
    let cmdStr: String
    var flags: CmdFlags

    init(text: String = "") {
        cmdStr = text
        flags = []
    }
}
