//
//  SessionLocalCommandHelp.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

struct LocalCommandHelpEntry: Equatable {
    let category: LocalCommandHelpCategory
    let keywords: [String]
    let syntax: String
    let detail: String?

    var helpTopic: String {
        return keywords.first ?? syntax
    }

    func matches(topic: String) -> Bool {
        let needle = topic.lowercased()
        return keywords.contains { keyword in
            let key = keyword.lowercased()
            return needle == key || needle.hasPrefix(key + " ") || key.hasPrefix(needle)
        }
    }
}

enum LocalCommandHelpCategory: String, CaseIterable {
    case session = "Session & output"
    case status = "Status bar"
    case world = "World flags & markers"
    case events = "Triggers & macros"
    case dump = "Dump listings"
    case windows = "Windows & sessions"
    case automation = "Automation"
}

enum SessionLocalCommandHelp {
    static let entries: [LocalCommandHelpEntry] = [
        LocalCommandHelpEntry(category: .session, keywords: ["history"], syntax: "history",
                              detail: "Lists recent commands entered in this session."),
        LocalCommandHelpEntry(category: .session, keywords: ["recall", "!"], syntax: "recall <n>  (shorthand: !<n>)",
                              detail: "Re-runs a command from history by its number."),
        LocalCommandHelpEntry(category: .session, keywords: ["clear screen"], syntax: "clear screen",
                              detail: "Clears the output pane for this session."),
        LocalCommandHelpEntry(category: .session, keywords: ["link"], syntax: "link <url> \"<label>\" #RRGGBB",
                              detail: "Inserts a colored hyperlink into the output pane."),
        LocalCommandHelpEntry(category: .session, keywords: ["help"], syntax: "help [<command>]",
                              detail: "Shows this help. Tap a command in the list for details."),
        LocalCommandHelpEntry(category: .session, keywords: ["upload"], syntax: "upload <file-path>",
                              detail: "Sends a local text file to the connected world as raw bytes. "
                                  + "Savitar does not parse or interpret the file contents. "
                                  + "Use a POSIX path or ~; quote paths that contain spaces."),
        LocalCommandHelpEntry(category: .session, keywords: ["capture"], syntax: "capture",
                              detail: "Toggles ad-hoc capture of session output to a plain-text file. "
                                  + "Run again to stop. The file path is a link that opens the capture "
                                  + "in a Savitar text window. Separate from World Settings → Output logging."),

        LocalCommandHelpEntry(category: .status, keywords: ["set status"], syntax: "set status output|input <message>",
                              detail: "Sets custom text on the output or input status bar."),
        LocalCommandHelpEntry(category: .status, keywords: ["close stats"], syntax: "close stats",
                              detail: "Hides the connection statistics bar."),
        LocalCommandHelpEntry(category: .status, keywords: ["close status"], syntax: "close status output|input",
                              detail: "Clears the output or input status bar message."),

        LocalCommandHelpEntry(category: .world, keywords: ["set ansi"], syntax: "set ansi on|off",
                              detail: "Toggles interpretation of ANSI color and style codes."),
        LocalCommandHelpEntry(category: .world, keywords: ["set html"], syntax: "set html on|off",
                              detail: "Toggles interpretation of HTML tags in server output."),
        LocalCommandHelpEntry(category: .world, keywords: ["set echo"], syntax: "set echo on|off",
                              detail: "Toggles echoing sent commands to the output pane."),
        LocalCommandHelpEntry(category: .world, keywords: ["set cronly"], syntax: "set cronly on|off",
                              detail: "When echo is off, shows only a line break after each sent command."),
        LocalCommandHelpEntry(category: .world, keywords: ["set autoclose"], syntax: "set autoclose on|off",
                              detail: "Toggles whether the session closes automatically on disconnect."),
        LocalCommandHelpEntry(
            category: .world,
            keywords: ["set marker"],
            syntax: "set marker command|macro|wildcard <text>",
            detail: "Sets the prefix that identifies commands, macros, or wildcards."
        ),
        LocalCommandHelpEntry(category: .world, keywords: ["set macro"], syntax: "set macro \"<name>\" <value>",
                              detail: "Sets a session macro variable used in command expansion."),
        LocalCommandHelpEntry(category: .world, keywords: ["add world"], syntax: "add world <XML>",
                              detail: nil),

        LocalCommandHelpEntry(category: .events, keywords: ["enable trigger"], syntax: "enable trigger \"<name>\"",
                              detail: "Enables a trigger by name."),
        LocalCommandHelpEntry(category: .events, keywords: ["disable trigger"], syntax: "disable trigger \"<name>\"",
                              detail: "Disables a trigger by name."),
        LocalCommandHelpEntry(category: .events, keywords: ["add macro"], syntax: "add macro <XML>",
                              detail: "Adds a macro from XML to the current world."),
        LocalCommandHelpEntry(category: .events, keywords: ["add trigger"], syntax: "add trigger <XML>",
                              detail: "Adds a trigger from XML to the current world."),
        LocalCommandHelpEntry(category: .events, keywords: ["regex"], syntax: "regex \"<text>\" \"<pattern>\"",
                              detail: "Tests whether text matches a regular expression pattern."),

        LocalCommandHelpEntry(category: .dump, keywords: ["dump"], syntax: "dump",
                              detail: "Lists all dump subcommands."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump colors"], syntax: "dump colors",
                              detail: "Lists the world color palette."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump macros"], syntax: "dump macros",
                              detail: "Lists macros defined in the current world."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump triggers"], syntax: "dump triggers",
                              detail: "Lists triggers defined in the current world."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump worlds"], syntax: "dump worlds",
                              detail: "Lists all configured worlds."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump aliases"], syntax: "dump aliases",
                              detail: nil),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump connection"], syntax: "dump connection",
                              detail: "Lists connection state for the current session "
                                  + "(address, status, streams, flags)."),
        LocalCommandHelpEntry(category: .dump, keywords: ["dump variables"], syntax: "dump variables",
                              detail: "Lists scratch variables for this session "
                                  + "(from triggers, ##set macro, ##regex)."),

        LocalCommandHelpEntry(category: .windows, keywords: ["broadcast"], syntax: "broadcast <command>",
                              detail: "Sends a command to every open session window."),
        LocalCommandHelpEntry(category: .windows, keywords: ["select window"], syntax: "select window \"<title>\"",
                              detail: "Brings a session window to the front by title."),
        LocalCommandHelpEntry(category: .windows, keywords: ["close window"], syntax: "close window \"<title>\"",
                              detail: "Closes a session window by title."),
        LocalCommandHelpEntry(category: .windows, keywords: ["open text window"], syntax: "open text window",
                              detail: "Opens a new untitled Savitar plain-text window."),
        LocalCommandHelpEntry(category: .windows, keywords: ["send window"], syntax: "send window \"<title>\" <msg>",
                              detail: "Appends text to a Savitar plain-text window whose title contains "
                                  + "the quoted name."),

        LocalCommandHelpEntry(category: .automation, keywords: ["wait"], syntax: "wait <seconds> [<command>]",
                              detail: "Pauses, then optionally runs another local command."),
        LocalCommandHelpEntry(category: .automation, keywords: ["play"], syntax: "play <sound-name>",
                              detail: "Plays a system sound by name—the same sounds listed in trigger Audio Cue. "
                                  + "Quote names that contain spaces.")
    ]

    static func html(marker: String, topic: String?) -> String {
        let escapedMarker = escape(marker)
        if let topic, !topic.isEmpty {
            return topicHelpHTML(marker: marker, escapedMarker: escapedMarker, topic: topic)
        }
        return fullHelpHTML(marker: marker, escapedMarker: escapedMarker)
    }

    static func plainText(marker: String, topic: String?) -> String {
        if let topic, !topic.isEmpty {
            return topicHelpPlain(marker: marker, topic: topic)
        }
        return fullHelpPlain(marker: marker)
    }

    private static func fullHelpHTML(marker: String, escapedMarker: String) -> String {
        var sections = ""
        for category in LocalCommandHelpCategory.allCases {
            let items = entries.filter { $0.category == category }
            guard !items.isEmpty else { continue }
            var rows = ""
            for entry in items {
                rows += """
                <li>\(commandLink(entry: entry, marker: marker, escapedMarker: escapedMarker))</li>
                """
            }
            sections += """
            <section class="savitar-help-section">
            <h4>\(escape(category.rawValue))</h4>
            <ul class="savitar-help-commands">\(rows)</ul>
            </section>
            """
        }
        return """
        <div class="savitar-help">
        <h3>Savitar local commands</h3>
        <p class="savitar-help-lead">Local commands are handled by Savitar and are \
        <strong>not</strong> sent to the game server. Your command marker is \
        <span class="savitar-help-marker">\(escapedMarker)</span>.</p>
        <p class="savitar-help-lead">Click a command below for syntax and details.</p>
        \(sections)
        </div>
        """
    }

    private static func topicHelpHTML(marker: String, escapedMarker: String, topic: String) -> String {
        guard let entry = matchingEntry(for: topic) else {
            return """
            <div class="savitar-help savitar-help-topic">
            \(backLink(marker: marker))
            <p class="savitar-help-missing">No help for \
            <span class="savitar-help-marker">\(escape(topic))</span>.</p>
            </div>
            """
        }
        let title = entry.helpTopic
        let detailBlock: String
        if let detail = entry.detail, !detail.isEmpty {
            detailBlock = "<p class=\"savitar-help-detail-text\">\(escape(detail))</p>"
        } else {
            detailBlock = ""
        }
        return """
        <div class="savitar-help savitar-help-topic">
        \(backLink(marker: marker))
        <h3>\(escape(title))</h3>
        <p class="savitar-help-syntax-line">\(escapedMarker)\(escape(entry.syntax))</p>
        \(detailBlock)
        </div>
        """
    }

    private static func backLink(marker: String) -> String {
        let cmd = helpXchCommand(marker: marker, topic: nil)
        return """
        <p class="savitar-help-nav"><a xch_cmd="\(escapeAttribute(cmd))" \
        class="savitar-help-back">← All local commands</a></p>
        """
    }

    private static func commandLink(entry: LocalCommandHelpEntry, marker: String, escapedMarker: String) -> String {
        let cmd = helpXchCommand(marker: marker, topic: entry.helpTopic)
        let label = "\(escapedMarker)\(escape(entry.syntax))"
        let hint = "Help for \(entry.helpTopic)"
        return """
        <a xch_cmd="\(escapeAttribute(cmd))" xch_hint="\(escapeAttribute(hint))" \
        class="savitar-help-cmd">\(label)</a>
        """
    }

    private static func helpXchCommand(marker: String, topic: String?) -> String {
        if let topic, !topic.isEmpty {
            return "\(marker)help \(topic)"
        }
        return "\(marker)help"
    }

    private static func fullHelpPlain(marker: String) -> String {
        var lines = [
            "[SAVITAR] Local commands (not sent to the server)",
            "Command marker: \(marker)",
            ""
        ]
        for entry in entries {
            lines.append("\(marker)\(entry.syntax)")
        }
        lines.append("")
        return lines.joined(separator: "\n")
    }

    private static func topicHelpPlain(marker: String, topic: String) -> String {
        guard let entry = matchingEntry(for: topic) else {
            return "[SAVITAR] No help for \"\(topic)\". Type \(marker)help for the full list.\n"
        }
        var lines = [
            "[SAVITAR] Local command: \(topic)",
            "Syntax: \(marker)\(entry.syntax)"
        ]
        if let detail = entry.detail, !detail.isEmpty {
            lines.append(detail)
        }
        lines.append("")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func matchingEntry(for topic: String) -> LocalCommandHelpEntry? {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let exact = entries.first(where: { $0.keywords.contains { $0.lowercased() == trimmed.lowercased() } }) {
            return exact
        }
        let matches = entries.filter { $0.matches(topic: trimmed) }
        return matches.max(by: { lhs, rhs in
            bestKeywordLength(in: lhs, for: trimmed) < bestKeywordLength(in: rhs, for: trimmed)
        })
    }

    private static func bestKeywordLength(in entry: LocalCommandHelpEntry, for topic: String) -> Int {
        let needle = topic.lowercased()
        return entry.keywords
            .filter { $0.lowercased().hasPrefix(needle) || needle.hasPrefix($0.lowercased()) }
            .map(\.count)
            .max() ?? 0
    }

    private static func escape(_ value: String) -> String {
        return XchCmdLinkProcessor.escapeText(value)
    }

    private static func escapeAttribute(_ value: String) -> String {
        return XchCmdLinkProcessor.escapeAttribute(value)
    }
}
