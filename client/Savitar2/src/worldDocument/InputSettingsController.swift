//
//  InputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class InputSettingsController: NSViewController {
    @IBOutlet var noEchoRadio: NSButton!
    @IBOutlet var echoCROnlyRadio: NSButton!
    @IBOutlet var echoAllRadio: NSButton!

    @objc dynamic var stickyCommands: Bool {
        get {
            guard let world = representedObject as? World else { return false }
            return world.flags.contains(.stickyCmds)
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            if value {
                world.flags.insert(.stickyCmds)
            } else {
                world.flags.remove(.stickyCmds)
            }
        }
    }

    @objc dynamic var cmdMarker: String {
        get {
            guard let world = representedObject as? World else { return "##" }
            return world.cmdMarker
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.cmdMarker = value
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let world = representedObject as? World else { return }

        noEchoRadio.state = !world.flags.contains(.echoCmds) && !world.flags.contains(.echoCR) ? .on : .off
        echoCROnlyRadio.state = world.flags.contains(.echoCR) ? .on : .off
        echoAllRadio.state = world.flags.contains(.echoCmds) ? .on : .off
    }

    @IBAction func echoRadioButtonChanged(_: AnyObject) {
        guard let world = representedObject as? World else { return }

        if noEchoRadio.state == .on {
            world.flags.remove([.echoCmds, .echoCR])
        } else if echoCROnlyRadio.state == .on {
            world.flags.remove(.echoCmds)
            world.flags.insert(.echoCR)
        } else {
            world.flags.remove(.echoCR)
            world.flags.insert(.echoCmds)
        }
    }
}
