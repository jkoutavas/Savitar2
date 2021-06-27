//
//  OutputSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 05/07/21.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class OutputSettingsController: NSViewController {
    @IBOutlet var appendLoggingRadio: NSButton!
    @IBOutlet var overwriteLoggingRadio: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let world = representedObject as? World else { return }
        appendLoggingRadio.state = world.loggingType == World.LoggingType.append ? .on : .off
        overwriteLoggingRadio.state = world.loggingType == World.LoggingType.overwrite ? .on : .off
    }

    @objc dynamic var logfilePath: String {
        get {
            guard let world = representedObject as? World else { return "" }
            return world.logfilePath
        }
        set(value) {
            guard let world = representedObject as? World else { return }
            world.logfilePath = value
        }
    }

    @IBAction func loggingRadioButtonChanged(_: AnyObject) {
        guard let world = representedObject as? World else { return }

        if appendLoggingRadio.state == .on {
            world.loggingType = World.LoggingType.append
        } else {
            world.loggingType = World.LoggingType.overwrite
        }
    }

    @IBAction func fileSaveAction(_: AnyObject) {
        guard let world = representedObject as? World else { return }
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["txt"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Spet your log file's location"
        savePanel.message = "Choose a folder and a name to store your log."
        savePanel.prompt = "Set now"
        savePanel.begin { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let fileUrl = savePanel.url else { return }
                world.logfilePath = fileUrl.path
            }
        }
    }
}
