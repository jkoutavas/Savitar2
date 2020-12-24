//
//  WorldWizardController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/22/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class WizardWorldController: World {
    @objc dynamic var worldIsOkay: Bool {
        return name.count > 0 && telnetString.count > 0
    }
}

class WorldWizardController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.representedObject = WizardWorldController(world: World())
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.view.window?.close()
    }

    @IBAction func doneAction(_ sender: Any) {
        self.view.window?.close()
    }
}
