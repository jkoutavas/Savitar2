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

    /// Base name (no extension) for Save As and print-to-PDF defaults.
    var preferredFilenameBase: String {
        if let name = world?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return Self.sanitizedFilename(name)
        }
        if let url = fileURL {
            return url.deletingPathExtension().lastPathComponent
        }
        return "Untitled"
    }

    private static func sanitizedFilename(_ name: String) -> String {
        var result = name
        for invalid in ["/", ":", "\0"] {
            result = result.replacingOccurrences(of: invalid, with: "-")
        }
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }

    override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
        let prepared = super.prepareSavePanel(savePanel)
        savePanel.nameFieldStringValue = preferredFilenameBase
        return prepared
    }

    /// World Picker and session restoration open untitled documents with `makeUntitledDocument`;
    /// they must be registered or File → Open Recent and live session capture behave incorrectly.
    func registerWithDocumentControllerIfNeeded() {
        let controller = NSDocumentController.shared
        guard !controller.documents.contains(where: { $0 === self }) else { return }
        controller.addDocument(self)
    }

    override func save(to url: URL,
                       ofType typeName: String,
                       for saveOperation: NSDocument.SaveOperationType,
                       completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: saveOperation) { error in
            if error == nil {
                self.registerWithDocumentControllerIfNeeded()
                NSDocumentController.shared.noteNewRecentDocumentURL(url)
                AppContext.shared.syncOpenSessions()
            }
            completionHandler(error)
        }
    }

    lazy var store = reactionsStore(undoManagerProvider: { self.undoManager! })

    override func close() {
        _ = stopSessionCapture()
        super.close()
        session?.close()
        AppContext.shared.syncOpenSessions()
    }

    override func makeWindowControllers() {
        guard let world = self.world else { return }

        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier("Document Window Controller"))
            as? WindowController else { return }
        self.windowController = windowController

        addWindowController(windowController)

        session = Session(world: world, sessionHandler: self)
        sessionViewController = windowController.contentViewController as? SessionViewController
        sessionViewController?.session = session
        sessionViewController?.outputViewController?.session = session
        guard let inputVC = sessionViewController?.inputViewController else { return }
        inputVC.session = session
        windowController.updateViews(world, wordWrap: session?.wordWrapEnabled ?? false, applyPaneLayout: true)
        showWelcomeBanner()
        session?.connectAndRun()
    }

    private func showWelcomeBanner() {
        let marker = world?.cmdMarker ?? "##"
        let html = SavitarWelcome.html(commandMarker: marker, linkColorHex: world?.linkColor.toHex)
        outputHTML(html)
    }

    override func read(from data: Data, ofType _: String) throws {
        self.world = World()
        guard let world = self.world else { return }

        let xml = XML.parse(data)
        try parse(xml: xml[DocumentElemIdentifier])

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
        world = fromWorld
        session?.world = fromWorld
    }

    /*
     * Produce XML-based data for a v2 Savitar world document
     */
    override func data(ofType _: String) throws -> Data {
        let docElem = try toXMLElement()
        let xml = XMLDocument(rootElement: docElem)
        let xmlStr = try xml.xmlString.prettyXMLFormat()
        if let data = xmlStr.data(using: String.Encoding.utf8) {
            return data
        } else {
            throw NSError(domain: "Savitar2", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode document XML"])
        }
    }

    // ***************************

    // MARK: - SessionHandlerProtocol

    // ***************************

    func output(result: OutputResult, skipCapture: Bool) {
        func output(string: String) {
            guard let svc = sessionViewController else { return }
            guard let outputVC = svc.outputViewController else { return }
            outputVC.output(string: string, skipCapture: skipCapture)
        }

        guard let world = self.world else { return }

        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[NSAttributedString.Key.font] = NSFont(name: world.fontName, size: world.fontSize)
        switch result {
        case let .success(message):
            attributes[NSAttributedString.Key.foregroundColor] = world.foreColor
            output(string: message)
        case let .error(error):
            attributes[NSAttributedString.Key.foregroundColor] = NSColor.red
            output(string: error)
        }
    }

    func outputEchoBack(_ text: String, skipCapture: Bool) {
        guard let outputVC = sessionViewController?.outputViewController else { return }
        outputVC.outputEchoBack(text, skipCapture: skipCapture)
    }

    func connectionStatusChanged(status: ConnectionStatus) {
        switch status {
        case .BindStart, .ConnectRetry:
            sessionViewController?.select(panel: .Connecting)

        case .ConnectComplete:
            sessionViewController?.select(panel: .Input)
            windowController?.reapplyPaneLayoutFromResolution()

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

    func outputLink(url: String, label: String, colorHex: String?) {
        let resolvedColor = colorHex ?? world?.linkColor.toHex
        guard let outputVC = sessionViewController?.outputViewController else { return }
        outputVC.outputLink(url: url, label: label, colorHex: resolvedColor)
    }

    func outputHTML(_ html: String, skipCapture: Bool = false) {
        guard let outputVC = sessionViewController?.outputViewController else { return }
        outputVC.outputHTML(html, skipCapture: skipCapture)
    }

    func commandHistory() -> [String] {
        guard let svc = sessionViewController else { return [] }
        guard let inputVC = svc.inputViewController else { return [] }
        return inputVC.commandHistory()
    }

    func setSessionStatus(pane: SessionStatusPane, text: String) {
        sessionViewController?.setStatus(pane: pane, text: text)
    }

    func closeSessionStatusBars() {
        sessionViewController?.clearStatusBars()
    }

    func closeSessionStatus(pane: SessionStatusPane) {
        sessionViewController?.closeStatus(pane: pane)
    }

    func recallCommand(at index: Int) {
        let history = commandHistory()
        guard index > 0, index <= history.count else {
            output(result: .success(
                "[SAVITAR] Recall parameter must be in range 1 to \(history.count)\n"
            ))
            return
        }
        sessionViewController?.inputViewController?.recallCmd(index: index)
    }

    func clearOutputScreen() {
        sessionViewController?.outputViewController?.outputView.clear()
    }

    func refreshSessionDisplay() {
        guard let world = world else { return }
        sessionViewController?.outputViewController?.setStyle(world: world)
        sessionViewController?.outputViewController?.setLogging(world: world)
        sessionViewController?.applyStatusBarStyle(world: world)
    }

    func insertWorldTrigger(_ trigger: Trigger) {
        guard let world = world else { return }
        world.triggerMan.add(trigger)
        let triggers = world.triggerMan.get()
        store.dispatch(InsertTriggerAction(trigger: trigger, atIndex: triggers.count - 1))
        updateChangeCount(.changeDone)
    }

    func insertWorldMacro(_ macro: Macro) {
        guard let world = world else { return }
        world.macroMan.add(macro)
        let macros = world.macroMan.get()
        store.dispatch(InsertMacroAction(macro: macro, atIndex: macros.count - 1))
        updateChangeCount(.changeDone)
    }

    func syncTriggerEnabled(_ trigger: Trigger, scope: SessionTriggerScope, enabled: Bool) {
        let action: TriggerAction = enabled ? .enable(trigger.objectID) : .disable(trigger.objectID)
        switch scope {
        case .world:
            store.dispatch(action)
            updateChangeCount(.changeDone)
        case .universal:
            AppContext.shared.universalReactionsStore.dispatch(action)
        }
    }

    func worldTriggers() -> [Trigger] {
        if let state = store.state {
            return state.triggerList.items
        }
        return world?.triggerMan.get() ?? []
    }

    func worldMacros() -> [Macro] {
        if let state = store.state {
            return state.macroList.items
        }
        return world?.macroMan.get() ?? []
    }

    var isSessionCapturing: Bool {
        return sessionViewController?.outputViewController?.isCapturing ?? false
    }

    func beginSessionCapture() -> SessionCaptureBeginResult {
        guard let outputVC = sessionViewController?.outputViewController else { return .failed }
        guard !outputVC.isCapturing else { return .failed }

        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["txt", "log"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Capture session output"
        savePanel.message = "Choose a folder and name for the capture file."
        savePanel.prompt = "Start capture"
        savePanel.nameFieldStringValue = Self.suggestedCaptureFilename(for: world)

        if let logPath = world?.logfilePath, !logPath.isEmpty {
            savePanel.directoryURL = URL(fileURLWithPath: logPath).deletingLastPathComponent()
        }

        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return .cancelled
        }

        return outputVC.startCapture(at: url.path) ? .started(path: url.path) : .failed
    }

    func stopSessionCapture() -> String? {
        return sessionViewController?.outputViewController?.stopCapture()
    }

    private static func suggestedCaptureFilename(for world: World?) -> String {
        let base: String
        if let name = world?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            base = sanitizedFilename(name)
        } else {
            base = "Untitled"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HHmmss"
        let stamp = formatter.string(from: Date())
        return "\(base) capture \(stamp).txt"
    }

    override func printDocument(_: Any?) {
        sessionViewController?.outputViewController?
            .printOutput(suggestedFilename: preferredFilenameBase)
    }

    // ***************************

    // MARK: - SavitarXMLProtocol

    // ***************************

    // These are the MacroElemIdentifier attributes
    enum DocumentAttribIdentifier: String {
        case type = "TYPE"
        case version = "VERSION"
    }

    func parse(xml: XML.Accessor) throws {
        for attribute in xml.attributes {
            switch attribute.key {
            case DocumentAttribIdentifier.type.rawValue:
                if attribute.value != type {
                    throw NSError(domain: "Savitar2", code: 3,
                                  userInfo: [NSLocalizedDescriptionKey: "Unexpected document type"])
                }
            case DocumentAttribIdentifier.version.rawValue:
                if let v = Int(attribute.value) {
                    version = v
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
