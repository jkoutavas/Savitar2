//
//  TelnetURLHandler.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Opens `telnet://` URLs from outside the app (browser/mail helper) or from output links.
enum TelnetURLHandler {
    static let scheme = "telnet"
    static let defaultPort: UInt32 = 23

    /// Prevents duplicate windows when GURL and `application(_:open:)` both deliver the same URL.
    private static var openingKeys = Set<String>()

    static func parse(_ url: URL) -> (host: String, port: UInt32)? {
        guard url.scheme?.lowercased() == scheme else { return nil }
        guard let host = url.host, !host.isEmpty else { return nil }

        let portValue: UInt32
        if let urlPort = url.port, urlPort > 0, urlPort <= Int(UInt32.max) {
            portValue = UInt32(urlPort)
        } else {
            portValue = defaultPort
        }
        return (host, portValue)
    }

    static func matchingWorld(host: String, port: UInt32, in worlds: [World]) -> World? {
        worlds.first { world in
            world.port == port && world.host.caseInsensitiveCompare(host) == .orderedSame
        }
    }

    static func open(_ url: URL) {
        guard !isRunningTests else { return }
        guard let parsed = parse(url) else { return }

        DispatchQueue.main.async {
            open(host: parsed.host, port: parsed.port)
        }
    }

    static func open(host: String, port: UInt32) {
        guard !isRunningTests else { return }
        guard !host.isEmpty else { return }

        let key = "\(host.lowercased()):\(port)"
        if let existing = existingDocument(host: host, port: port) {
            bringToFront(existing)
            return
        }
        guard !openingKeys.contains(key) else { return }
        openingKeys.insert(key)
        defer { openingKeys.remove(key) }

        let worlds = AppContext.shared.worldPickerStore.state?.worldList.items ?? []
        let worldToOpen: World
        if let matched = matchingWorld(host: host, port: port, in: worlds) {
            worldToOpen = matched
        } else {
            worldToOpen = ephemeralWorld(host: host, port: port)
        }

        do {
            let document = try NSDocumentController.shared.makeUntitledDocument(ofType: DocumentV2.FileType)
            if let worldDocument = document as? Document {
                worldDocument.loadAndShow(world: worldToOpen)
            }
            NSApp.activate(ignoringOtherApps: true)
        } catch {
            NSLog("Savitar: failed to open telnet://%@:%u — %@", host, port, String(describing: error))
        }
    }

    static func ephemeralWorld(host: String, port: UInt32) -> World {
        let world = World()
        world.name = host
        world.host = host
        world.port = port
        return world
    }

    private static func existingDocument(host: String, port: UInt32) -> Document? {
        for document in NSDocumentController.shared.documents {
            guard let worldDocument = document as? Document,
                  let world = worldDocument.world else { continue }
            if world.port == port,
               world.host.caseInsensitiveCompare(host) == .orderedSame {
                return worldDocument
            }
        }
        return nil
    }

    private static func bringToFront(_ document: Document) {
        for controller in document.windowControllers {
            controller.window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
