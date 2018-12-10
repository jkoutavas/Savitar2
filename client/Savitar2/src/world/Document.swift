//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa

class Document: NSDocument, OutputProtocol {
    let world = World()

    var endpoint: Endpoint?
    var splitViewController: SplitViewController?

    override func close() {
        super.close()
        endpoint?.close()
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("Document Window Controller"))
            as? WindowController else { return }

        self.addWindowController(windowController)
        windowController.world = world

        output(result: .success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port: world.port, host: world.host, outputter: self)
        splitViewController = windowController.contentViewController as? SplitViewController
        guard let inputVC = splitViewController?.inputViewController else { return }
        inputVC.endpoint = endpoint
        endpoint?.connectAndRun()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        try world.read(from: data)
    }

    func output(result: OutputResult) {
        func output(string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
            guard let svc = splitViewController else { return }
             guard let outputVC = svc.outputViewController else { return }
            let outputView = outputVC.textView

            outputView?.textStorage?.append(NSAttributedString(string: string, attributes: attributes))
            outputView?.scrollToEndOfDocument(nil)
        }

        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[NSAttributedString.Key.font] = NSFont(name: world.fontName, size: world.fontSize)
        switch result {
        case .success(let message):
            attributes[NSAttributedString.Key.foregroundColor] = world.foreColor
            output(string: message, attributes: attributes)
        case .error(let error):
            attributes[NSAttributedString.Key.foregroundColor] = NSColor.red
            output(string: error, attributes: attributes)
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        world.version = 2
        return try world.data()
    }
}
