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

enum SessionLocalCommand: Equatable {
    case dump
    case history
    case setStatus(pane: SessionStatusPane, message: String)
    case closeStats
    case unknown(body: String)
}

enum SessionLocalCommands {
    static func parse(_ body: String) -> SessionLocalCommand {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown(body: body) }

        let words = trimmed.split(whereSeparator: { $0.isWhitespace })
        guard let command = words.first?.lowercased() else { return .unknown(body: body) }

        switch command {
        case "dump":
            return words.count == 1 ? .dump : .unknown(body: body)
        case "history":
            return words.count == 1 ? .history : .unknown(body: body)
        case "close":
            return parseClose(words: words, body: body)
        case "set":
            return parseSet(trimmed, words: words, body: body)
        default:
            return .unknown(body: body)
        }
    }

    private static func parseClose(words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count == 2, words[1].lowercased() == "stats" else {
            return .unknown(body: body)
        }
        return .closeStats
    }

    private static func parseSet(_ trimmed: String, words: [Substring], body: String) -> SessionLocalCommand {
        guard words.count >= 4,
              words[1].lowercased() == "status",
              let pane = statusPane(named: words[2]) else {
            return .unknown(body: body)
        }

        let messageStart = words[3].startIndex
        let message = String(trimmed[messageStart...])
        return .setStatus(pane: pane, message: message)
    }

    private static func statusPane(named name: Substring) -> SessionStatusPane? {
        switch name.lowercased() {
        case "output":
            return .output
        case "input":
            return .input
        default:
            return nil
        }
    }
}
