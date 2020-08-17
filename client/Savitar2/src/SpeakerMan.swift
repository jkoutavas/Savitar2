//
//  SpeakerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/16/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import AudioToolbox
import Cocoa

struct SpeakerMan {
    // https://stackoverflow.com/a/38445571/246887
    var soundNames: [String] {
        let soundPaths: [String] = ["~/Library/Sounds", "/Library/Sounds", "/Network/Library/Sounds",
            "/System/Library/Sounds"]

        var names: [String] = ["Click"] // "Click" is part of the app's resource bundle
        for soundPath in soundPaths {
            let path = soundPath.contains("~") ? soundPath.expandingTildeInPath : soundPath
            let dirEnum = FileManager().enumerator(atPath: path)
            while let file = dirEnum?.nextObject() as? String {
                if !file.contains(".DS_Store") {
                    names.append(file.fileName())
                }
            }
        }
        return names
    }

    func playSound(name: String) {
        NSSound(named: NSSound.Name(name))?.play()
    }
}
