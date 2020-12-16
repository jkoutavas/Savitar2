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

    @IBOutlet weak var progress: NSProgressIndicator?

    @IBAction func closeAction(_ sender: AnyObject) {
        session?.reallyCloseWindow()
    }

    @IBAction func connectAction(_ sender: AnyObject) {
        session?.connectAndRun()
    }

    @IBAction func stopAction(_ sender: AnyObject) {
        session?.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let prog = self.progress {
            prog.startAnimation(self)
        }
    }
}
