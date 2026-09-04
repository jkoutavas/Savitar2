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
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let isLinkClick = navigationAction.navigationType == .linkActivated
            || navigationAction.navigationType == .other
        guard isLinkClick else {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased()
        if scheme == TelnetURLHandler.scheme {
            TelnetURLHandler.open(url)
            decisionHandler(.cancel)
            return
        }

        if scheme == "http" || scheme == "https" || scheme == "mailto" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
