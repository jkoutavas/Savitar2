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
    var makeAppend = false
    var lastAppendID = 0

    lazy var outputView: OutputView = {

        class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
            func userContentController(_ userContentController: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                print("📗webkit: \(message.body)")
            }
        }

        let userContentController = WKUserContentController()
        userContentController.add(LoggingMessageHandler(), name: "logging")
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController

 //        webViewConfig.preferences.setValue(true, forKey: "developerExtrasEnabled")

        let outputView = OutputView(frame: .zero, configuration: webViewConfig)
        outputView.translatesAutoresizingMaskIntoConstraints = false

        return outputView
    }()

    override func viewDidLoad() {
        // we add a layer so we can set background color
        view.wantsLayer = true
        super.viewDidLoad()

        view.addSubview(outputView)
        NSLayoutConstraint.activate([
            outputView.topAnchor
                .constraint(equalTo: self.view.topAnchor),
            outputView.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            outputView.bottomAnchor
                .constraint(equalTo: self.view.bottomAnchor),
            outputView.rightAnchor
                .constraint(equalTo: self.view.rightAnchor)
        ])
     }

    func output(string: String) {
        let appending = makeAppend // appending will be true if last operation was an append
        makeAppend = !string.endsWithNewline() // determine now if we're going to need to append
        outputView.output(string: string, makeAppend: makeAppend, appending: appending, appendID: lastAppendID)
        if !makeAppend {
            lastAppendID += 1 // now prepare for the next element
        }
    }

    func setStyle(world: World) {
        outputView.setStyle(world: world)
    }

    func printSource() {
        outputView.printSource()
    }
}
