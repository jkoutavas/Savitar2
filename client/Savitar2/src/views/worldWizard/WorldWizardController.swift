//
//  WorldWizardController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/22/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class WorldWizardController: NSViewController {
    var completionHandler: ((Bool, World?) -> Void)?

    @objc dynamic var world = World()
    @objc dynamic var worldIsOkay = false

    var hostObserver: NSKeyValueObservation?
    var nameObserver: NSKeyValueObservation?

    @IBAction func cancelAction(_ sender: Any) {
        completionHandler?(false, nil)
        self.view.window?.close()
    }

    @IBAction func doneAction(_ sender: Any) {
        completionHandler?(true, world)
        self.view.window?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameObserver = world.observe(\.name) { [unowned self] w, _ in
            self.worldIsOkay = w.name.count > 0 && w.host.count > 0
        }

        hostObserver = world.observe(\.host) { [unowned self] w, _ in
            self.worldIsOkay = w.name.count > 0 && w.host.count > 0
        }
    }
}
