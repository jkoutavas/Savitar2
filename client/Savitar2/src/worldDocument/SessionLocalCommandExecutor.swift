//
//  SessionLocalCommandExecutor.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser

enum SessionLocalCommandExecutor {
    static func execute(_ command: SessionLocalCommand, session: Session) {
        let handler = session.sessionHandler

        switch command {
        case .dump:
            handler.printSource()
        case let .dumpListing(target):
            dumpListing(target, session: session)
        case .history:
            info(session, commandHistoryText(session))
        case let .setStatus(pane, message):
            handler.setSessionStatus(pane: pane, text: message)
        case let .setWorldFlag(flag, enabled):
            setWorldFlag(flag, enabled: enabled, session: session)
        case let .setScratchVariable(name, value):
            session.world.variableMan.set(name, value: value)
        case let .setMarker(kind, value):
            setMarker(kind, value: value, session: session)
        case .closeStats:
            handler.closeSessionStatusBars()
        case let .closeStatus(pane):
            handler.closeSessionStatus(pane: pane)
        case let .closeWindow(title):
            closeWindow(title: title, session: session)
        case .clearScreen:
            handler.clearOutputScreen()
        case let .recall(index):
            handler.recallCommand(at: index)
        case let .broadcast(command):
            broadcast(command: command, excluding: session)
        case let .enableTrigger(name):
            setTriggerEnabled(name: name, enabled: true, session: session)
        case let .disableTrigger(name):
            setTriggerEnabled(name: name, enabled: false, session: session)
        case let .regex(testString, pattern):
            runRegex(testString: testString, pattern: pattern, session: session)
        case let .wait(seconds, followUp):
            scheduleWait(seconds: seconds, followUp: followUp, session: session)
        case let .addMacro(xml):
            addMacro(xml: xml, session: session)
        case let .addTrigger(xml):
            addTrigger(xml: xml, session: session)
        case let .selectWindow(title):
            if !selectWindow(title: title) {
                commandError(session, "Window \"\(title)\" not found.")
            }
        case let .link(url, label, colorHex):
            handler.outputLink(url: url, label: label, colorHex: colorHex)
        case let .help(topic):
            showHelp(topic: topic, session: session)
        case let .unknown(body):
            info(session, "Unknown local command: \(body)\n")
        }
    }

    // MARK: - Output helpers

    private static func info(_ session: Session, _ text: String) {
        session.sessionHandler.output(result: .success(text))
    }

    private static func commandError(_ session: Session, _ text: String) {
        session.sessionHandler.output(result: .success("[SAVITAR] \(text)\n"))
    }

    private static func showHelp(topic: String?, session: Session) {
        let marker = session.world.cmdMarker
        let html = SessionLocalCommandHelp.html(marker: marker, topic: topic)
        session.sessionHandler.outputHTML(html)
    }

    private static func commandHistoryText(_ session: Session) -> String {
        let history = session.sessionHandler.commandHistory()
        guard !history.isEmpty else {
            return "[SAVITAR] No command history.\n"
        }

        let width = String(history.count).count
        let lines = history.enumerated().map { index, command -> String in
            let number = String(format: "%\(width)d", index + 1)
            return "\(number)  \(command)"
        }
        return "[SAVITAR] Command history:\n\(lines.joined(separator: "\n"))\n"
    }

    // MARK: - World flags & markers

    private static func setWorldFlag(_ flag: SessionWorldFlag, enabled: Bool, session: Session) {
        switch flag {
        case .ansi:
            setFlag(.ansi, enabled: enabled, session: session)
        case .html:
            setFlag(.html, enabled: enabled, session: session)
        case .echo:
            setFlag(.echoCmds, enabled: enabled, session: session)
        case .cronly:
            setFlag(.crOnly, enabled: enabled, session: session)
        case .autoclose:
            setFlag(.autoClose, enabled: enabled, session: session)
        }
        session.sessionHandler.refreshSessionDisplay()
    }

    private static func setFlag(_ flag: WorldFlags, enabled: Bool, session: Session) {
        if enabled {
            session.world.flags.insert(flag)
        } else {
            session.world.flags.remove(flag)
        }
    }

    private static func setMarker(_ kind: SessionMarkerKind, value: String, session: Session) {
        switch kind {
        case .command:
            session.world.cmdMarker = value
        case .variable:
            session.world.varMarker = value
        case .wildcard:
            session.world.wildMarker = value
        }
    }

    // MARK: - Triggers

    private static func setTriggerEnabled(name: String, enabled: Bool, session: Session) {
        guard let match = findTrigger(named: name, session: session) else {
            commandError(session, "Trigger \"\(name)\" not found.")
            return
        }

        match.trigger.enabled = enabled
        session.sessionHandler.syncTriggerEnabled(match.trigger, scope: match.scope, enabled: enabled)
        let state = enabled ? "enabled" : "disabled"
        info(session, "Trigger \"\(match.trigger.name)\" \(state).\n")
    }

    private static func findTrigger(named name: String,
                                    session: Session) -> (trigger: Trigger, scope: SessionTriggerScope)? {
        if let trigger = session.sessionHandler.worldTriggers().first(where: { $0.name == name }) {
            return (trigger, .world)
        }
        if let trigger = session.universalTriggers.first(where: { $0.name == name }) {
            return (trigger, .universal)
        }
        return nil
    }

    // MARK: - Regex

    private static func runRegex(testString: String, pattern: String, session: Session) {
        let marker = session.world.varMarker
        var output = "regex \"\(testString)\" \"\(pattern)\" ==> "

        let options: NSRegularExpression.Options = []
        guard let expression = try? NSRegularExpression(pattern: pattern, options: options) else {
            commandError(session, "Invalid regular expression.")
            return
        }

        let nsRange = NSRange(testString.startIndex ..< testString.endIndex, in: testString)
        guard let match = expression.firstMatch(in: testString, options: [], range: nsRange) else {
            info(session, "\(output)No match.\n")
            return
        }

        output += "success\n"
        for index in 0 ..< match.numberOfRanges {
            let range = match.range(at: index)
            guard range.location != NSNotFound,
                  let swiftRange = Range(range, in: testString) else { continue }
            let capture = String(testString[swiftRange])
            session.world.variableMan.set("\(index)", value: capture)
            output += "    \(marker)\(index) =\"\(capture)\"\n"
        }
        info(session, output)
    }

    // MARK: - Wait

    private static func scheduleWait(seconds: Int, followUp: String?, session: Session) {
        guard let followUp, !followUp.isEmpty else { return }
        let delay = max(0, seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [weak session] in
            session?.submitServerCmd(cmd: Command(text: followUp))
        }
    }

    // MARK: - Add macro / trigger

    private static func addMacro(xml: String, session: Session) {
        do {
            let accessor = try XML.parse(xml)
            let elem = accessor[MacroElemIdentifier]
            if case .failure = elem {
                throw SessionLocalCommandError.invalidXML
            }
            let macro = Macro()
            try macro.parse(xml: elem)
            session.sessionHandler.insertWorldMacro(macro)
            info(session, "Macro \"\(macro.name)\" added.\n")
        } catch {
            commandError(session, "Could not parse macro XML.")
        }
    }

    private static func addTrigger(xml: String, session: Session) {
        do {
            let accessor = try XML.parse(xml)
            let elem = accessor[TriggerElemIdentifier]
            if case .failure = elem {
                throw SessionLocalCommandError.invalidXML
            }
            let trigger = Trigger()
            try trigger.parse(xml: elem)
            if trigger.style != nil {
                trigger.style!.formOnOff()
            }
            session.sessionHandler.insertWorldTrigger(trigger)
            info(session, "Trigger \"\(trigger.name)\" added.\n")
        } catch {
            commandError(session, "Could not parse trigger XML.")
        }
    }

    // MARK: - Dump listings

    private static func dumpListing(_ target: SessionDumpTarget, session: Session) {
        switch target {
        case .colors:
            dumpColors(session: session)
        case .macros:
            dumpMacros(session: session)
        case .triggers:
            dumpTriggers(session: session)
        case .worlds:
            dumpWorlds(session: session)
        }
    }

    private static func dumpColors(session: Session) {
        var output = heading("Dump of all colors", level: 1)
        output += heading("universal colors", level: 2)
        let colorMan = AppContext.shared.prefs.colorMan
        for color in colorMan.get() {
            output += xmlLine(try? color.toXMLElement())
        }
        output += heading("End of Dump", level: 1)
        info(session, output)
    }

    private static func dumpMacros(session: Session) {
        var output = heading("Dump of all macros", level: 1)
        output += heading("universal macros", level: 2)
        let universal = AppContext.shared.universalReactionsStore.state?.macroList.items ?? []
        if universal.isEmpty {
            output += emptySectionNotice
        } else {
            for macro in universal {
                output += xmlLine(try? macro.toXMLElement())
            }
        }
        output += heading("world specific macros", level: 2)
        let worldMacros = session.sessionHandler.worldMacros()
        if worldMacros.isEmpty {
            output += emptySectionNotice
        } else {
            for macro in worldMacros {
                output += xmlLine(try? macro.toXMLElement())
            }
        }
        output += heading("End of Dump", level: 1)
        info(session, output)
    }

    private static func dumpTriggers(session: Session) {
        var output = heading("Dump of all triggers", level: 1)
        output += heading("universal triggers", level: 2)
        let universal = session.universalTriggers
        if universal.isEmpty {
            output += emptySectionNotice
        } else {
            for trigger in universal {
                output += xmlLine(try? trigger.toXMLElement())
            }
        }
        output += heading("world specific triggers", level: 2)
        let worldTriggers = session.sessionHandler.worldTriggers()
        if worldTriggers.isEmpty {
            output += emptySectionNotice
        } else {
            for trigger in worldTriggers {
                output += xmlLine(try? trigger.toXMLElement())
            }
        }
        output += heading("End of Dump", level: 1)
        info(session, output)
    }

    private static func dumpWorlds(session: Session) {
        var output = heading("Dump of all worlds", level: 1)
        let worlds = AppContext.shared.worldPickerStore.state?.worldList.items ?? []
        for world in worlds {
            output += xmlLine(try? world.toXMLElement())
        }
        output += heading("End of Dump", level: 1)
        info(session, output)
    }

    private static let emptySectionNotice = "    (none)\n"

    private static func heading(_ title: String, level: Int) -> String {
        let marker = String(repeating: "=", count: max(1, 7 - level))
        return "\n\(marker) \(title) \(marker)\n"
    }

    /// Escape XML so dump listings stay visible when the session uses HTML output mode.
    private static func xmlLine(_ element: XMLElement?) -> String {
        guard let element else { return "" }
        let raw = prettyXML(for: element)
        return htmlEntityEscape(raw) + "\n"
    }

    private static func prettyXML(for element: XMLElement) -> String {
        let document = XMLDocument(rootElement: element)
        let data = document.xmlData(options: .nodePrettyPrint)
        guard let formatted = String(data: data, encoding: .utf8) else {
            return stripXMLDeclaration(from: element.xmlString)
        }
        return stripXMLDeclaration(from: formatted)
    }

    private static func stripXMLDeclaration(from xml: String) -> String {
        let trimmed = xml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("<?xml") else { return trimmed + "\n" }
        guard let end = trimmed.range(of: "?>") else { return trimmed + "\n" }
        let body = trimmed[end.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        return body + "\n"
    }

    private static func htmlEntityEscape(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    // MARK: - Windows

    private static func closeWindow(title: String, session: Session) {
        guard let window = Self.window(matching: title) else {
            commandError(session, "Window \"\(title)\" not found.")
            return
        }
        window.close()
    }

    static func selectWindow(title: String) -> Bool {
        guard let window = window(matching: title) else { return false }
        window.makeKeyAndOrderFront(nil)
        return true
    }

    private static func window(matching title: String) -> NSWindow? {
        let needle = title.lowercased()
        for document in NSDocumentController.shared.documents {
            guard let window = document.windowControllers.first?.window else { continue }
            if window.title.lowercased().contains(needle) {
                return window
            }
        }
        return nil
    }

    // MARK: - Broadcast

    private static func broadcast(command: String, excluding source: Session) {
        for document in NSDocumentController.shared.documents {
            guard let worldDocument = document as? Document,
                  let session = worldDocument.session,
                  session !== source,
                  session.status == .ConnectComplete else { continue }
            session.submitServerCmd(cmd: Command(text: command))
        }
    }
}

private enum SessionLocalCommandError: Error {
    case invalidXML
}
