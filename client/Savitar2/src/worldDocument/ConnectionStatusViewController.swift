//
//  ConnectionStatusViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/27/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class ConnectionStatusViewController: NSViewController {
    var session: Session?

    @IBOutlet var progress: NSProgressIndicator?

    @IBAction func closeAction(_: AnyObject) {
        session?.reallyCloseWindow()
    }

    @IBAction func connectAction(_: AnyObject) {
        session?.connectAndRun()
    }

    @IBAction func stopAction(_: AnyObject) {
        session?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let prog = progress {
            prog.startAnimation(self)
        }
    }
}
