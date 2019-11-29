//
//  InputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/11/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class InputViewController: ViewController {

    public weak var endpoint: Endpoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Not setting the checkmark in the interface builder doesn't seem to work since OS X 10.9 Mavericks.
        // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
             // we're wrapping this in an async call so we call unwind the
            // keyDown event off the stack before clearing the string
            DispatchQueue.main.async { [unowned self] in
                if self.textView.string.count > 1 {
                    self.endpoint?.sendMessage(message: self.textView.string)
                }

                self.textView.string = ""
            }
        }
    }
}
