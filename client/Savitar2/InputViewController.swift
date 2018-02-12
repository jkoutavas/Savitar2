//
//  InputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/11/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class InputViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    // TODO: tie this into the connection run loop, so as to
                    // have it send this text to the server
                    print("Sending: \(self.textView.string)")
                }

                self.textView.string = ""
            }
        }
    }
}
