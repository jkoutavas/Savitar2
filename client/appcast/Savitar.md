### Added

- **Local commands (2.0 set)** — `##history`, `##recall` / `##!n`, `##clear screen`, status bars (`##set status`, `##close stats`, per-pane close), world flags and markers, scratch variables (`##set macro`), trigger enable/disable and XML add, `##dump` listings (pretty-printed, HTML-safe), `##regex`, `##wait`, `##broadcast`, window select/close; live Events store for world triggers/macros
- **`##help`** — HTML local-command reference grouped by category; tap a command (`xch_cmd`) to drill into syntax and a short description; back link to the full list; works even when **Interpret HTML tags** is off
- **`##link`** — insert a colored hyperlink into the output pane: `##link <url> "<label>" #RRGGBB`
- **`##capture`** — toggle ad-hoc session output capture to a plain-text file (save panel on start; run again to stop); capture path in the output pane is a link that opens the file in a Savitar text window; separate from World Settings → Output logging
- **`##upload`** — send a local text file to the connected world as raw bytes (`##upload <file-path>`); Savitar does not parse or interpret the file contents
- **`##open text window`** — open a new untitled Savitar plain-text window
- **`##send window`** — append text to a plain-text window by partial title match (`##send window "<title>" <msg>`)
- **`##dump connection`** / **`##dump variables`** — list session connection state or scratch `%%variables` in the output pane
- **`##play`** — play a system sound by name (same sound list as trigger Audio Cue; honors Mute Sound Cues)
- **`##add world`** — parse a `<WORLD …>` XML fragment and add it to the World Picker list
- **Echo-back color** — Savitar 1's echo-back highlight returns: echoed input, trigger-reply banners, and `[SAVITAR]` client messages render on the world's echo-back color (`ECHOBGCOLOR`, default soft yellow) in the output pane
- **Pueblo `xch_cmd` links** — `<a xch_cmd="…">` in HTML output becomes a clickable link; clicks send the command to the session (local commands when prefixed with the world marker, otherwise to the server)
- **Session welcome banner** — Savitar 1–style opening block at connect: bold **Welcome to Savitar**, version/copyright, website link, and a hint to type `##help`; single tight HTML block with one blank line before server output
- **Session status bars** — Savitar 1's per-pane status bars return: `##set status output|input <message>` shows a one-line strip at the top of the pane (variables expand in the message); `##close stats` hides both; strips render in **inverse** session colors for contrast — configurable styling is planned for 2.1
- **Macro Clicker** — floating button palette (Story 11): Savitar 1–style **Macro Clicker** window — periwinkle compass rose, green up/down arrows, whimsical green-outlined grid (1–9, a–f); all 15 grid cells are functional (`MACRO_A` … `MACRO_F` for a–f); direction + number buttons send bound macros to the frontmost session; **Window → Show Macro Clicker**; **⌘-click** to bind; hover caption; startup + mute prefs; v1 `ALIAS` XML import/export (18-entry imports preserve `MACRO_10` on **a** when saved)
- **Input editing keys** — **⌃E** (end of line), **⌃U** (clear input), **⌃W** (delete word backward) in the input pane (v1 parity; **⌃A** retained)

### Changed

- **Savitar Help** — Edit → Find… / Find Next / Find Previous / Use Selection for Find work in the bundled user guide (find bar above the help web view)
- **Help book** — fenced Markdown code blocks (` ```text `) render as monospace `<pre>` sections instead of showing raw backticks
- **Edit menu** — removed **Jump to Selection** (⌘J); little use in Savitar and did not apply to session output or help
- **Macro Clicker** — default letter-slot bindings use underscores (`MACRO_A` … `MACRO_F`) to match `MACRO_1` … `MACRO_9`; early hyphenated factory prefs upgrade on load
- **User guide** — documents `##link`, `##help`, `##capture`, `##upload`, `##open text window`, `##send window`, `##play`, and `##add world`; input editing keys **⌃E**, **⌃U**, **⌃W**

### Fixed

- **Session welcome** — banner was emitted before the output pane existed and never appeared; now outputs after the session view is wired up
- **Session output HTML** — multiline HTML embedded in JavaScript no longer breaks WebKit (`SyntaxError: Unexpected token '<'`); `##help` and other HTML fragments render reliably
- **Output link clicks** — `http`/`https` links in HTML output activate correctly (`.linkActivated` navigation policy)
- **Resolution overlay** — yellow variable-resolution box no longer sticks when the app is backgrounded, the window loses key, split-pane resize ends (mouse-up), or window live resize ends
- **HTML bold/strong** — `<strong>` / `<b>` and welcome title render bold despite the global output stylesheet `font` shorthand
- **Session restoration** — closing a world document before quitting no longer causes it to reopen on relaunch; prefs now persist the live open-document list (#92)
- **World Settings → Output** — log file picker opens as a sheet on the settings window; logging creates the log file when the path does not exist yet; log files use Unix line endings and plain text (ANSI stripped, HTML tags removed); session line splitting preserves source newlines so later output does not collapse the log into one line
- **Input pane height on connect** — bottom split no longer stays at the Connecting tab's storyboard height (~80px) after connect; divider restores to saved `inputRows` (default 2) on `ConnectComplete`
- **Input pane defaults for new worlds** — disabled shared `NSSplitView` autosave that let the previous session's divider override per-world `RESOLUTION`; pane measurement no longer mutates the live session `World` during resize notifications; World Picker sessions copy catalog worlds so layout changes do not corrupt shared prefs entries
- **File → Open Recent** — worlds opened from the World Picker or session restoration register with `NSDocumentController` and appear in recents after save; unit tests use an isolated UserDefaults suite so `xcodebuild test` no longer clears the developer install's recent-documents list (#97)

