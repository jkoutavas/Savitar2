//
//  OutputViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/12/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class OutputViewController: NSViewController {
    @IBOutlet var webView: WKWebView!

    func output(string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
        webView.output(string:string, attributes:attributes)
    }
    
    func setStyle(world: World) {
        webView.setStyle(world: world)
    }
}
