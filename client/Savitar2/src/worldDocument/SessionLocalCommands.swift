//
//  SessionLocalCommands.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

enum SessionStatusPane: Equatable {
    case output
    case input
}

enum SessionDumpTarget: Equatable {
    case colors
    case macros
    case triggers
    case worlds
    case connection
    case variables
}

enum SessionWorldFlag: Equatable {
    case ansi
    case html
    case echo
    case cronly
    case autoclose
}

enum SessionMarkerKind: Equatable {
    case command
    case variable
    case wildcard
}

enum SessionLocalCommand: Equatable {
    case dump
    case dumpListing(SessionDumpTarget)
    case history
    case setStatus(pane: SessionStatusPane, message: String)
    case setWorldFlag(SessionWorldFlag, enabled: Bool)
    case setScratchVariable(name: String, value: String)
    case setMarker(kind: SessionMarkerKind, value: String)
    case closeStats
    case closeStatus(pane: SessionStatusPane)
    case closeWindow(title: String)
    case clearScreen
    case recall(index: Int)
    case broadcast(command: String)
    case enableTrigger(name: String)
    case disableTrigger(name: String)
    case regex(testString: String, pattern: String)
    case wait(seconds: Int, followUp: String?)
    case addMacro(xml: String)
    case addTrigger(xml: String)
    case addWorld(xml: String)
    case selectWindow(title: String)
    case link(url: String, label: String, colorHex: String?)
    case help(topic: String?)
    case capture
    case upload(path: String)
    case openTextWindow
    case sendWindow(title: String, message: String)
    case play(soundName: String)
    case unknown(body: String)
}

enum SessionLocalCommands {
    static func parse(_ body: String) -> SessionLocalCommand {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown(body: body) }

        if trimmed.first == "!" {
            return parseBangRecall(trimmed, body: body)
        }

        let words = trimmed.split(whereSeparator: { $0.isWhitespace })
        guard let command = words.first?.lowercased() else { return .unknown(body: body) }

        switch command {
        case "add":
            return parseAdd(trimmed, words: words, body: body)
        case "broadcast":
            return parseBroadcast(trimmed, words: words, body: body)
        case "capture":
            return words.count == 1 ? .capture : .unknown(body: body)
        case "clear":
            return parseClear(words: words, body: body)
        case "close":
            return parseClose(trimmed, words: words, body: body)
        case "disable":
            return parseDisable(trimmed, words: words, body: body)
        case "dump":
            return parseDump(words: words, body: body)
        case "enable":
            return parseEnable(trimmed, words: words, body: body)
        case "history":
            return words.count == 1 ? .history : .unknown(body: body)
        case "help":
            return parseHelp(trimmed, words: words, body: body)
        case "link":
            return parseLink(trimmed, body: body)
        case "open":
            return parseOpen(words: words, body: body)
        case "play":
            return parsePlay(trimmed, words: words, body: body)
        case "recall":
            return parseRecall(words: words, body: body)
        case "regex":
            return parseRegex(trimmed, body: body)
        case "set":
            return parseSet(trimmed, words: words, body: body)
        case "select":
            return parseSelect(trimmed, words: words, body: body)
        case "send":
            return parseSend(trimmed, words: words, body: body)
        case "upload":
            return parseUpload(trimmed, words: words, body: body)
        case "wait":
            return parseWait(trimmed, words: words, body: body)
        default:
            return .unknown(body: body)
        }
    }

    // MARK: - Parsers

    private static func parseBangRecall(_ trimmed: String, body: String) -> SessionLocalCommand {
        let digits = trimmed.dropFirst().prefix(while: { $0.isNumber })
        guard !digits.isEmpty, let index = Int(digits) else {
            return .unknown(body: body)
        }
        return .recall(index: index)
    }

    private static func parseAdd(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        let kind = String(words[1].prefix(3)).lowercased()
        guard let payload = payload(afterLeadingWords: 2, in: trimmed), !payload.isEmpty else {
            return .unknown(body: body)
        }

        switch kind {
        case "mac":
            return .addMacro(xml: payload)
        case "tri":
            return .addTrigger(xml: payload)
        case "wor":
            return .addWorld(xml: payload)
        default:
            return .unknown(body: body)
        }
    }

    private static func parseBroadcast(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2,
              let command = payload(afterLeadingWords: 1, in: trimmed),
              !command.isEmpty else {
            return .unknown(body: body)
        }
        return .broadcast(command: command)
    }

    private static func parseClear(words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count == 2, words[1].lowercased().hasPrefix("scr") else {
            return .unknown(body: body)
        }
        return .clearScreen
    }

    private static func parseClose(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        let target = String(words[1].prefix(3)).lowercased()

        switch target {
        case "sta":
            if words.count == 2, words[1].lowercased() == "stats" {
                return .closeStats
            }
            guard words.count >= 3,
                  let pane = statusPane(named: words[2]) else {
                return .unknown(body: body)
            }
            return .closeStatus(pane: pane)
        case "win":
            guard let title = parseQuotedString(from: trimmed, afterWordIndex: 2) else {
                return .unknown(body: body)
            }
            return .closeWindow(title: title.value)
        default:
            if words.count == 2, words[1].lowercased() == "stats" {
                return .closeStats
            }
            return .unknown(body: body)
        }
    }

    private static func parseDisable(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2, words[1].lowercased().hasPrefix("tri") else {
            return .unknown(body: body)
        }
        if let quoted = parseQuotedString(from: trimmed, afterWordIndex: 2) {
            return .disableTrigger(name: quoted.value)
        }
        guard words.count >= 3 else { return .unknown(body: body) }
        return .disableTrigger(name: String(words[2]))
    }

    private static func parseDump(words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count == 1 else {
            guard words.count == 2 else { return .unknown(body: body) }
            switch String(words[1].prefix(3)).lowercased() {
            case "col":
                return .dumpListing(.colors)
            case "mac":
                return .dumpListing(.macros)
            case "tri":
                return .dumpListing(.triggers)
            case "wor":
                return .dumpListing(.worlds)
            case "con":
                return .dumpListing(.connection)
            case "var":
                return .dumpListing(.variables)
            default:
                return .unknown(body: body)
            }
        }
        return .dump
    }

    private static func parseEnable(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2, words[1].lowercased().hasPrefix("tri") else {
            return .unknown(body: body)
        }
        if let quoted = parseQuotedString(from: trimmed, afterWordIndex: 2) {
            return .enableTrigger(name: quoted.value)
        }
        guard words.count >= 3 else { return .unknown(body: body) }
        return .enableTrigger(name: String(words[2]))
    }

    private static func parseRecall(words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count == 2, let index = Int(words[1]) else {
            return .unknown(body: body)
        }
        return .recall(index: index)
    }

    private static func parseHelp(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 1 else { return .unknown(body: body) }
        if words.count == 1 {
            return .help(topic: nil)
        }
        let topic = payload(afterLeadingWords: 1, in: trimmed)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let topic, !topic.isEmpty else { return .help(topic: nil) }
        return .help(topic: topic)
    }

    private static func parseOpen(words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count == 3,
              words[1].lowercased().hasPrefix("tex"),
              words[2].lowercased().hasPrefix("win") else {
            return .unknown(body: body)
        }
        return .openTextWindow
    }

    private static func parsePlay(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        if let quoted = parseQuotedString(from: trimmed, afterWordIndex: 1) {
            let name = quoted.value.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return .unknown(body: body) }
            return .play(soundName: name)
        }
        guard let name = payload(afterLeadingWords: 1, in: trimmed), !name.isEmpty else {
            return .unknown(body: body)
        }
        return .play(soundName: name)
    }

    private static func parseLink(_ trimmed: String, body: String) -> SessionLocalCommand {
        guard let payload = payload(afterLeadingWords: 1, in: trimmed),
              payload.first == "<",
              let closeIndex = payload.firstIndex(of: ">") else {
            return .unknown(body: body)
        }

        let urlStart = payload.index(after: payload.startIndex)
        let url = String(payload[urlStart ..< closeIndex])
        guard !url.isEmpty else { return .unknown(body: body) }

        var remainder = String(payload[payload.index(after: closeIndex)...])
            .trimmingCharacters(in: .whitespaces)

        var label: String?
        if remainder.hasPrefix("\"") {
            guard let quoted = parseQuotedString(at: remainder.startIndex, in: remainder) else {
                return .unknown(body: body)
            }
            label = quoted.value
            remainder = quoted.remainder.trimmingCharacters(in: .whitespaces)
        }

        var colorHex: String?
        if remainder.hasPrefix("#") {
            colorHex = String(remainder.dropFirst())
            if colorHex?.isEmpty == true {
                return .unknown(body: body)
            }
        } else if !remainder.isEmpty {
            return .unknown(body: body)
        }

        return .link(url: url, label: label ?? url, colorHex: colorHex)
    }

    private static func parseRegex(_ trimmed: String, body: String) -> SessionLocalCommand {
        guard let first = parseQuotedString(from: trimmed, afterWordIndex: 1) else {
            return .unknown(body: body)
        }
        let remainder = first.remainder.trimmingCharacters(in: .whitespaces)
        guard let second = parseQuotedString(at: remainder.startIndex, in: remainder) else {
            return .unknown(body: body)
        }
        return .regex(testString: first.value, pattern: second.value)
    }

    private static func parseSelect(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2, words[1].lowercased().hasPrefix("win") else {
            return .unknown(body: body)
        }
        guard let title = parseQuotedString(from: trimmed, afterWordIndex: 2) else {
            return .unknown(body: body)
        }
        return .selectWindow(title: title.value)
    }

    private static func parseSend(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2, words[1].lowercased().hasPrefix("win") else {
            return .unknown(body: body)
        }
        guard let title = parseQuotedString(from: trimmed, afterWordIndex: 2) else {
            return .unknown(body: body)
        }
        let message = title.remainder.trimmingCharacters(in: .whitespaces)
        guard !message.isEmpty else { return .unknown(body: body) }
        return .sendWindow(title: title.value, message: message)
    }

    private static func parseUpload(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        if let quoted = parseQuotedString(from: trimmed, afterWordIndex: 1) {
            return .upload(path: quoted.value)
        }
        guard let path = payload(afterLeadingWords: 1, in: trimmed), !path.isEmpty else {
            return .unknown(body: body)
        }
        return .upload(path: path)
    }

    private static func parseSet(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        let subject = String(words[1].prefix(3)).lowercased()

        switch subject {
        case "ans":
            return parseWorldFlag(words: words, body: body, flag: .ansi)
        case "aut":
            return parseWorldFlag(words: words, body: body, flag: .autoclose)
        case "cro":
            return parseWorldFlag(words: words, body: body, flag: .cronly)
        case "ech":
            return parseWorldFlag(words: words, body: body, flag: .echo)
        case "htm":
            return parseWorldFlag(words: words, body: body, flag: .html)
        case "mac":
            guard let quoted = parseQuotedString(from: trimmed, afterWordIndex: 2),
                  !quoted.value.isEmpty else {
                return .unknown(body: body)
            }
            let value = quoted.remainder.trimmingCharacters(in: .whitespaces)
            guard !value.isEmpty else { return .unknown(body: body) }
            return .setScratchVariable(name: quoted.value, value: value)
        case "mar":
            return parseSetMarker(trimmed, words: words, body: body)
        case "sta":
            return parseSetStatus(trimmed, words: words, body: body)
        default:
            return .unknown(body: body)
        }
    }

    private static func parseSetStatus(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 4,
              words[1].lowercased() == "status",
              let pane = statusPane(named: words[2]) else {
            return .unknown(body: body)
        }

        let messageStart = words[3].startIndex
        let message = String(trimmed[messageStart...])
        return .setStatus(pane: pane, message: message)
    }

    private static func parseSetMarker(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 3 else { return .unknown(body: body) }
        let kind: SessionMarkerKind
        switch String(words[2].prefix(3)).lowercased() {
        case "com":
            kind = .command
        case "mac":
            kind = .variable
        case "wil":
            kind = .wildcard
        default:
            return .unknown(body: body)
        }
        guard let value = payload(afterLeadingWords: 3, in: trimmed) else {
            return .unknown(body: body)
        }
        guard !value.isEmpty else { return .unknown(body: body) }
        return .setMarker(kind: kind, value: String(value.prefix(2)))
    }

    private static func parseWorldFlag(words: [Substring], body: String,
                                       flag: SessionWorldFlag) -> SessionLocalCommand {
        guard words.count == 3 else { return .unknown(body: body) }
        switch words[2].lowercased() {
        case "on":
            return .setWorldFlag(flag, enabled: true)
        case "off":
            return .setWorldFlag(flag, enabled: false)
        default:
            return .unknown(body: body)
        }
    }

    private static func parseWait(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 2 else { return .unknown(body: body) }
        let digits = words[1].prefix(while: { $0.isNumber })
        guard !digits.isEmpty, let seconds = Int(digits) else {
            return .unknown(body: body)
        }
        let followUp = payload(afterLeadingWords: 2, in: trimmed)
        return .wait(seconds: seconds, followUp: followUp)
    }

    // MARK: - Helpers

    private static func payload(afterLeadingWords count: Int, in text: String) -> String? {
        var remaining = text[...]
        for _ in 0 ..< count {
            guard let range = remaining.range(of: #"\S+"#, options: .regularExpression) else {
                return nil
            }
            remaining = remaining[range.upperBound...]
        }
        let payload = remaining.trimmingCharacters(in: .whitespaces)
        return payload.isEmpty ? nil : payload
    }

    private static func statusPane(named name: Substring) -> SessionStatusPane? {
        switch name.lowercased() {
        case "output", "out":
            return .output
        case "input", "inp":
            return .input
        default:
            return nil
        }
    }

    static func parseQuotedString(from text: String, afterWordIndex: Int) -> (value: String, remainder: String)? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard let payload = payload(afterLeadingWords: afterWordIndex, in: trimmed) else {
            return nil
        }
        return parseQuotedString(at: payload.startIndex, in: payload)
    }

    private static func parseQuotedString(at start: String.Index,
                                          in text: String) -> (value: String, remainder: String)? {
        var index = start
        while index < text.endIndex, text[index].isWhitespace {
            index = text.index(after: index)
        }
        guard index < text.endIndex, text[index] == "\"" else { return nil }

        index = text.index(after: index)
        var value = ""
        while index < text.endIndex {
            let char = text[index]
            if char == "\"" {
                let remainderIndex = text.index(after: index)
                let remainder = remainderIndex < text.endIndex ? String(text[remainderIndex...]) : ""
                return (value, remainder)
            }
            if char == "\\" {
                let next = text.index(after: index)
                guard next < text.endIndex else { return nil }
                value.append(text[next])
                index = text.index(after: next)
            } else {
                value.append(char)
                index = text.index(after: index)
            }
        }
        return nil
    }
}
