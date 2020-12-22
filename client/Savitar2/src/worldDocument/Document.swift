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

class Document: NSDocument, SessionHandlerProtocol, SavitarXMLProtocol {

    let type = "Savitar World"
    var version = 1 // start with the assumption that a v1 world XML is being parsed

    var windowController: WindowController?
    var world: World?
    var session: Session?
    var sessionViewController: SessionViewController?

    var suppressChangeCount: Bool = false

    lazy var store = reactionsStore(undoManagerProvider: { self.undoManager! })

    override func close() {
        super.close()
        session?.close()
    }

    override func makeWindowControllers() {
        guard let world = self.world else { return }

        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("Document Window Controller"))
            as? WindowController else { return }
        self.windowController = windowController

        self.addWindowController(windowController)
        windowController.updateViews(world)

        output(result: .success("Welcome to Savitar 2.0!\n\n"))
        session = Session(world: world, sessionHandler: self)
        sessionViewController = windowController.contentViewController as? SessionViewController
        sessionViewController?.session = session
        guard let inputVC = sessionViewController?.inputViewController else { return }
        inputVC.session = session
        session?.connectAndRun()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        self.world = World()
        guard let world = self.world else { return }

        let xml = XML.parse(data)
        try self.parse(xml: xml[DocumentElemIdentifier])

        store.dispatch(SetMacrosAction(macros: world.macroMan.get()))
        store.dispatch(SetTriggersAction(triggers: world.triggerMan.get()))
    }

    override func updateChangeCount(_ change: NSDocument.ChangeType) {
        if !suppressChangeCount {
            super.updateChangeCount(change)
        } else {
            suppressChangeCount = false
        }
    }

    func worldDidChange(fromWorld: World) {
        self.world = fromWorld
        session?.world = fromWorld
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
    // MARK: - SessionHandlerProtocol
    //***************************

    func output(result: OutputResult) {
        func output(string: String) {
            guard let svc = sessionViewController else { return }
            guard let outputVC = svc.outputViewController else { return }
            outputVC.output(string: string)
        }

        guard let world = self.world else { return }

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

    func connectionStatusChanged(status: ConnectionStatus) {
        switch status {
        case .BindStart:
            sessionViewController?.select(panel: .Connecting)

        case .ConnectComplete:
            sessionViewController?.select(panel: .Input)

        case .DisconnectComplete:
            sessionViewController?.select(panel: .Offline)

        case .ReallyCloseWindow:
            windowController?.reallyClose()
        default:
            break
        }
    }

    func printSource() {
        guard let svc = sessionViewController else { return }
        guard let outputVC = svc.outputViewController else { return }
        outputVC.printSource()
    }

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    // These are the MacroElemIdentifier attributes
    enum DocumentAttribIdentifier: String {
        case type = "TYPE"
        case version = "VERSION"
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
            default:
                Swift.print("skipping document attribute \(attribute.key)")
            }
        }

        guard let world = self.world else { return }
        try world.parse(xml: xml[WorldElemIdentifier])
    }

    func toXMLElement() throws -> XMLElement {
        let docElem = XMLElement(name: DocumentElemIdentifier)

        version = 2

        guard let world = self.world else { return XMLElement() }

        docElem.addAttribute(name: DocumentAttribIdentifier.type.rawValue, stringValue: type)
        docElem.addAttribute(name: DocumentAttribIdentifier.version.rawValue, stringValue: "\(version)")

        if let triggers = store.state?.triggerList.items {
            world.triggerMan = TriggerMan(triggers)
        }

        if let macros = store.state?.macroList.items {
            world.macroMan = MacroMan(macros)
        }

        let worldElem = try world.toXMLElement()
        docElem.addChild(worldElem)

        return docElem
    }
}
