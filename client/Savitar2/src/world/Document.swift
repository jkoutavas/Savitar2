//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let DocumentElemIdentifier = "DOCUMENT"

class Document: NSDocument, OutputProtocol, SavitarXMLProtocol {

    let type = "Savitar World"
    var version = 1 // start with the assumption that a v1 world XML is being parsed
    var GUID = NSUUID().uuidString

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
        endpoint = Endpoint(world: world, outputter: self)
        splitViewController = windowController.contentViewController as? SplitViewController
        guard let inputVC = splitViewController?.inputViewController else { return }
        inputVC.endpoint = endpoint
        endpoint?.connectAndRun()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        let xml = XML.parse(data)
        try self.parse(xml: xml[DocumentElemIdentifier])

        world.triggerMan.undoManager = undoManager
        world.variableMan.undoManager = undoManager
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

    /*
     * Produce XML-based data for a v2 Savitar world document
     */
    override func data(ofType typeName: String) throws -> Data {
        let docElem = try self.toXMLElement()
        let xml = XMLDocument(rootElement: docElem)
        let xmlStr = try xml.xmlString.prettyXMLFormat()
        if let data = xmlStr.data(using: String.Encoding.utf8) {
            return data
        } else {
            throw NSError()
        }
    }

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    // These are the VariableElemIdentifier attributes
    enum DocumentAttribIdentifier: String {
        case type = "TYPE"
        case version = "VERSION"
        case GUID = "GUID"
    }

    func parse(xml: XML.Accessor) throws {
        for attribute in xml.attributes {
            switch attribute.key {
            case DocumentAttribIdentifier.type.rawValue:
                if attribute.value != self.type {
                    throw NSError()
                }
            case DocumentAttribIdentifier.version.rawValue:
                if let v = Int(attribute.value) {
                    self.version = v
                }
            case DocumentAttribIdentifier.GUID.rawValue:
                self.GUID = attribute.value
            default:
                Swift.print("skipping document attribute \(attribute.key)")
            }
        }

        try self.world.parse(xml: xml[WorldElemIdentifier])
    }

    func toXMLElement() throws -> XMLElement {
        let docElem = XMLElement(name: DocumentElemIdentifier)

        version = 2

        docElem.addAttribute(name: DocumentAttribIdentifier.type.rawValue, stringValue: type)
        docElem.addAttribute(name: DocumentAttribIdentifier.version.rawValue, stringValue: "\(version)")
        docElem.addAttribute(name: DocumentAttribIdentifier.GUID.rawValue, stringValue: GUID)

        let worldElem = try world.toXMLElement()
        docElem.addChild(worldElem)

        return docElem
    }
}
