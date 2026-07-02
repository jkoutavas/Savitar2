//
//  WindowRestoration.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

let OpenSessionsElemIdentifier = "OPEN_SESSIONS"
let OpenSessionElemIdentifier = "SESSION"
let OpenWindowElemIdentifier = "WINDOW"

enum SavedOpenSession: Equatable {
    case file(URL)
    case pickerWorld(SavitarObjectID)
    case worldPickerWindow
    case eventsWindow

    enum AttributeIdentifier: String {
        case file = "FILE"
        case worldID = "WORLD_ID"
        case type = "TYPE"
    }

    enum WindowType: String {
        case worldPicker
        case eventsWindow
    }
}

enum WindowRestoration {
    static func captureOpenSessions(from context: AppContext) -> [SavedOpenSession] {
        var sessions: [SavedOpenSession] = []

        for document in NSDocumentController.shared.documents {
            guard let worldDocument = document as? Document else { continue }

            if let fileURL = document.fileURL {
                sessions.append(.file(fileURL))
            } else if let world = worldDocument.world {
                sessions.append(.pickerWorld(world.objectID))
            }
        }

        return sessions
    }

    static func restoreSavedSessions(_ sessions: [SavedOpenSession], in context: AppContext) {
        for session in sessions {
            switch session {
            case let .file(url):
                restoreFileSession(url)
            case let .pickerWorld(objectID):
                restorePickerSession(objectID, in: context)
            case .worldPickerWindow, .eventsWindow:
                // Auxiliary windows are controlled by startup prefs, not session restoration.
                break
            }
        }
    }

    static func parseOpenSessions(xml: XML.Accessor) -> [SavedOpenSession] {
        var sessions: [SavedOpenSession] = []

        for elem in xml[OpenSessionsElemIdentifier][OpenSessionElemIdentifier] {
            if let filePath = elem.attributes[SavedOpenSession.AttributeIdentifier.file.rawValue] {
                let path = NSString(string: filePath).expandingTildeInPath
                sessions.append(.file(URL(fileURLWithPath: path)))
            } else if let worldIDValue = elem.attributes[SavedOpenSession.AttributeIdentifier.worldID.rawValue],
                      let objectID = SavitarObjectID(identifier: worldIDValue) {
                sessions.append(.pickerWorld(objectID))
            }
        }

        for elem in xml[OpenSessionsElemIdentifier][OpenWindowElemIdentifier] {
            guard let typeValue = elem.attributes[SavedOpenSession.AttributeIdentifier.type.rawValue],
                  let windowType = SavedOpenSession.WindowType(rawValue: typeValue) else { continue }

            switch windowType {
            case .worldPicker:
                sessions.append(.worldPickerWindow)
            case .eventsWindow:
                sessions.append(.eventsWindow)
            }
        }

        return sessions
    }

    static func openSessionsElement(for sessions: [SavedOpenSession]) -> XMLElement? {
        guard !sessions.isEmpty else { return nil }

        let openSessionsElem = XMLElement(name: OpenSessionsElemIdentifier)

        for session in sessions {
            switch session {
            case let .file(url):
                let sessionElem = XMLElement(name: OpenSessionElemIdentifier)
                sessionElem.addAttribute(name: SavedOpenSession.AttributeIdentifier.file.rawValue,
                                         stringValue: url.path)
                openSessionsElem.addChild(sessionElem)
            case let .pickerWorld(objectID):
                let sessionElem = XMLElement(name: OpenSessionElemIdentifier)
                sessionElem.addAttribute(name: SavedOpenSession.AttributeIdentifier.worldID.rawValue,
                                         stringValue: objectID.identifier)
                openSessionsElem.addChild(sessionElem)
            case .worldPickerWindow:
                let windowElem = XMLElement(name: OpenWindowElemIdentifier)
                windowElem.addAttribute(name: SavedOpenSession.AttributeIdentifier.type.rawValue,
                                      stringValue: SavedOpenSession.WindowType.worldPicker.rawValue)
                openSessionsElem.addChild(windowElem)
            case .eventsWindow:
                let windowElem = XMLElement(name: OpenWindowElemIdentifier)
                windowElem.addAttribute(name: SavedOpenSession.AttributeIdentifier.type.rawValue,
                                      stringValue: SavedOpenSession.WindowType.eventsWindow.rawValue)
                openSessionsElem.addChild(windowElem)
            }
        }

        return openSessionsElem
    }

    private static func restoreFileSession(_ url: URL) {
        let openDocuments = NSDocumentController.shared.documents
        if openDocuments.contains(where: { $0.fileURL == url }) {
            return
        }

        NSDocumentController.shared.openDocument(withContentsOf: url,
                                                 display: true,
                                                 completionHandler: { _, _, _ in })
    }

    private static func restorePickerSession(_ objectID: SavitarObjectID, in context: AppContext) {
        guard let worlds = context.worldPickerStore.state?.worldList.items else { return }
        guard let world = worlds.first(where: { $0.objectID == objectID }) else { return }

        let openWorldIDs = NSDocumentController.shared.documents.compactMap { document -> SavitarObjectID? in
            guard let worldDocument = document as? Document else { return nil }
            return worldDocument.world?.objectID
        }

        if openWorldIDs.contains(objectID) {
            return
        }

        do {
            let document = try NSDocumentController.shared.makeUntitledDocument(ofType: DocumentV2.FileType)
            if let worldDocument = document as? Document {
                worldDocument.loadAndShow(world: world)
            }
        } catch {}
    }
}
