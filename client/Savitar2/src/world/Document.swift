//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa

class Document: NSDocument, OutputProtocol {
    let DocumentElemIdentifier = "DOCUMENT"

    var world = World()

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
        windowController.updateViews(world)

        output(result: .success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port: world.port, host: world.host, outputter: self)
        splitViewController = windowController.contentViewController as? SplitViewController
        guard let inputVC = splitViewController?.inputViewController else { return }
        inputVC.endpoint = endpoint
        endpoint?.connectAndRun()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        try world.parseXML(from: data)
    }

    func output(result: OutputResult) {
        func output(string: String) {
            guard let svc = splitViewController else { return }
            guard let outputVC = svc.outputViewController else { return }
            outputVC.output(string: string)
         }

        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[NSAttributedString.Key.font] = NSFont(name: world.fontName, size: world.fontSize)
        switch result {
        case .success(let message):
            attributes[NSAttributedString.Key.foregroundColor] = world.foreColor
            output(string: message)
        case .error(let error):
            attributes[NSAttributedString.Key.foregroundColor] = NSColor.red
            output(string: error)
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        /*
         * Write-out XML for a v2 Savitar world document
         *
         * You may wonder "why XML in this modern age? Why not do a PLIST or codable thing? Or use JSON?"
         * Answer: We stay away from Apple specific formats like PLIST and codable because we want the
         * world document to be easily readable from anywhere, any platform. True, in this modern age,
         * JSON would fit that requirement, but, there's something to be said about having some semblence
         * still with the v1 document's format, and it's not that hard to read and write XML. So: XML it is
         */

        let docElem = XMLElement(name: DocumentElemIdentifier)
        guard let type = XMLNode.attribute(withName: "TYPE", stringValue: "Savitar World") as? XMLNode else {
            throw NSError()
        }
        docElem.addAttribute(type)

        world.version = 2
        let worldElem = try world.toXMLElement()
        docElem.addChild(worldElem)

        let xml = XMLDocument(rootElement: docElem)
        return xml.xmlString.data(using: String.Encoding.utf8)!
    }
}
