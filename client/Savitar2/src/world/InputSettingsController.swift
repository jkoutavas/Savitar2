//
//  InputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class InputSettingsController: NSViewController {
    @IBOutlet weak var noEchoRadio: NSButton!
    @IBOutlet weak var echoCROnlyRadio: NSButton!
    @IBOutlet weak var echoAllRadio: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let wc = self.representedObject as? WorldController else { return }

        noEchoRadio.state = !wc.world.flags.contains(.echoCmds) && !wc.world.flags.contains(.echoCR) ? .on : .off
        echoCROnlyRadio.state = wc.world.flags.contains(.echoCR) ? .on : .off
        echoAllRadio.state = wc.world.flags.contains(.echoCmds) ? .on : .off
    }

    @IBAction func echoRadioButtonChanged(_ sender: AnyObject) {
        guard let wc = self.representedObject as? WorldController else { return }

        if noEchoRadio.state == .on {
            wc.world.flags.remove([.echoCmds, .echoCR])
        } else if echoCROnlyRadio.state == .on {
            wc.world.flags.remove(.echoCmds)
            wc.world.flags.insert(.echoCR)
        } else {
            wc.world.flags.remove(.echoCR)
            wc.world.flags.insert(.echoCmds)
        }
    }
}
