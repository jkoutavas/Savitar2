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

        if navigationAction.navigationType == .linkActivated,
           url.scheme == "http" || url.scheme == "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        if navigationAction.navigationType == .other,
           url.scheme == "http" || url.scheme == "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
