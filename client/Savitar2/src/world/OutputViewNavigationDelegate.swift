//
//  OutputViewNavigationDelegate.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class OutputViewNavigationDelegate: NSViewController, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }
}
