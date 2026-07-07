# Savitar 2 User Guide

_Last updated July 7, 2026._

This guide explains how to use Savitar 2. It is being written incrementally; see [Stories.md](Stories.md) **Story 9** for the plan to complete the full guide.

Savitar 2 is intended to behave like Savitar 1.x for day-to-day use. Where behavior matches v1, this guide describes that parity explicitly.

---

## Getting started

1. **Launch Savitar** and open the **World Picker** (or use **File → Open World…**).
2. **Double-click a world** (for example Alter Aeon) to open a session window.
3. Type a command in the **input** pane at the bottom and press **Return**.
4. Open the **Events** window (**World → Events Window**) to add triggers or macros.

**Tip:** Open **Help → Savitar Help** (⌘?) anytime to return to this guide offline.

---

## Speech

Savitar can speak text in three ways:

1. **Continuous speech** — automatically reads incoming **world output** (text the server sends to your session).
2. **Event speech** — trigger-based speech configured in the **Events** window (per trigger voice and phrase).
3. **Ad-hoc speech** — speak a **selection** in the input or output pane via **Edit → Speech → Speak Selected Text**.

All speech uses the English voices installed on your Mac. On macOS 10.15 and later, Savitar uses the modern system speech engine (`AVSpeechSynthesizer`). On earlier macOS versions, it uses the legacy `NSSpeechSynthesizer` engine instead.

### Continuous speech

Continuous speech is the feature most users mean when they turn speech on for a MUD or telnet session.

**What it does**

- When enabled, each chunk of text that arrives in the **output** pane is spoken aloud.
- ANSI color and style codes are stripped before speaking; you hear plain text.
- Continuous speech uses the **voice** and **rate** from app Speech settings (see below). These are **global** preferences—the same defaults Savitar 1 used—not per-world settings.
- Text you type in the **input** line is **not** spoken unless the world echoes it back as output.

**How to turn it on**

1. Open **Settings…** (⌘,) or **Audio → Speech Settings…**
2. Select the **Speech** toolbar tab
3. Check **Continuous speech enabled**
4. Choose a **Voice** and adjust **Rate** if desired
5. Click the speaker icon next to the voice menu to hear a sample phrase

Settings save immediately when you change them.

**Requirements**

- macOS 10.15 or later for continuous speech (the Speech pane shows a footnote on older systems).
- **Mute Speaking Cues** must be **off** in the **Audio** menu or **Settings → Audio** pane. When muted, both continuous speech and trigger speech are suppressed.

### Event (trigger) speech

Triggers in the **Events** window can play audio cues when matched:

| Cue type | Behavior |
|----------|----------|
| **Sound** | Plays a system or custom sound file |
| **Speak event** | Speaks the text that matched the trigger |
| **Say text** | Speaks a fixed phrase you configure |

Each trigger can use its own voice. The speech **rate** slider in Speech settings still applies to trigger speech, matching Savitar 1.

Trigger speech respects the same mute flags as continuous speech:

- **Mute Sound Cues** — suppresses trigger sounds only
- **Mute Speaking Cues** — suppresses trigger speech and continuous speech

### Edit → Speech

| Menu item | What it does |
|-----------|--------------|
| **Speak Selected Text** | Speak the selected text in the **input** or **output** pane (enabled when the active pane has a selection, or when the output pane is focused) |

Select text in either pane, then choose **Edit → Speech → Speak Selected Text**. This matches Savitar 1’s **Edit → Speech → Start Speaking**, which worked on selections in both WASTE text panes. Savitar 2 uses the same menu location (HIG) with a clearer label and Savitar’s voice engine.

### Audio menu

| Menu item | What it does |
|-----------|--------------|
| **Mute Sound Cues** | Toggle trigger sound effects on/off |
| **Mute Speaking Cues** | Toggle all spoken output (triggers + continuous speech) |
| **Flush Speech Buffer** (⌘L) | Stop speech immediately and discard queued utterances (enabled only while speech is active) |
| **Speech Settings…** | Opens **Settings → Speech** |

**Menu split (v1 parity + HIG)**

| Command | Menu | Purpose |
|---------|------|---------|
| **Speak Selected Text** | **Edit → Speech** | Read selected text in input or output (replaces v1 **Start Speaking**) |
| **Flush Speech Buffer** (⌘L) | **Audio** | Stop Savitar speech and clear its queue (continuous + trigger speech) |

Savitar 1 did not include **Stop Speaking** as a separate Savitar command — that was the macOS counterpart to **Start Speaking**. Queued speech is cleared with **Flush Speech Buffer**, not Stop Speaking.

### Speech settings reference

Open **Settings…** → **Speech**:

| Control | Description |
|---------|-------------|
| **Continuous speech enabled** | Master switch for reading world output aloud |
| **Voice** | Default English voice for continuous speech and **Speak Selected Text** |
| **Speaker button** | Plays a sample sentence with the selected voice |
| **Rate** | Slow (5) through Fast (20); **10** is normal speed. Affects continuous speech, trigger speech, and ad-hoc speech |

Voice and rate changes take effect on the next spoken utterance; you do not need to restart the app or reconnect to a world.

### Tips

- If nothing is spoken after enabling continuous speech, confirm **Mute Speaking Cues** is off and that the world is actually sending text to the output pane.
- Long bursts of output are spoken as they arrive; use **Flush Speech Buffer** (⌘L) to skip ahead when you have fallen behind.
- Importing Savitar 1 preferences preserves your continuous speech enabled flag, voice name, and rate from the v1 prefs file.

---

## Menus

Savitar’s menu bar follows standard macOS conventions. A few items are Savitar-specific; others are provided by the system because Savitar is a document-based app. On recent macOS versions, **File** may show additional items (such as **Duplicate**, **Rename…**, and **Move To…**) that replace or supplement older template entries—the behavior described here matches what you see at runtime.

World document windows, the **World Picker**, and the **Events** windows each enable the commands that apply to the frontmost window.

### Savitar menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **About Savitar** | — | Shows the standard About box with version information. |
| **Settings…** | ⌘, | Opens the app **Settings** window (toolbar panes: Startup, Input & Display, Audio, Updates, Speech). Changes apply immediately; there is no Save button. |
| **Services** | — | Standard macOS Services submenu for the current selection (when a supporting service is installed). |
| **Hide Savitar** | ⌘H | Hides all Savitar windows. |
| **Hide Others** | ⌥⌘H | Hides every app except Savitar. |
| **Show All** | — | Un-hides other applications. |
| **Quit Savitar** | ⌘Q | Quits the app. Open world documents are closed according to each window’s save state. |

See [Speech settings reference](#speech-settings-reference) for the **Speech** pane. Other Settings panes are documented in upcoming guide chapters.

### File menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **New World Document…** | ⌘N | Opens the **World Picker** so you can choose a world to connect to. Double-clicking a world opens a new session in an untitled document window. |
| **New Text Document** | ⇧⌘T | Opens a new plain-text editor window for notes, logs, or other `.txt` / `.text` / `.log` files (Savitar 1 text-document parity). |
| **Open…** | ⌘O | Opens a saved `.world` document or a plain-text file (`.txt`, `.text`, `.log`). Savitar reads both Savitar 2 and legacy Savitar 1 world files. |
| **Open Recent** | — | Lists recently opened world documents. Choose **Clear Menu** at the bottom to reset the list. |
| **Close** | ⌘W | Closes the frontmost window (World Picker, world document, or Events window). If a world document has unsaved changes, macOS prompts you to save. |
| **Save** | ⌘S | Saves the active world document. For an untitled document, opens the save sheet first. The default filename is the **world’s name** (for example, `Alter Aeon.world`). |
| **Duplicate** | ⇧⌘S | *(System menu item.)* Creates a new untitled copy of the current world document with the same settings, triggers, and macros. The copy is not saved until you choose **Save**. |
| **Rename…** | — | *(System menu item.)* Renames the saved file for the current world document in place. |
| **Move To…** | — | *(System menu item.)* Moves the saved world file to another folder. |
| **Revert To** | — | *(System submenu.)* Discards unsaved changes and restores the document to a previously saved version on disk. |
| **Share** | — | *(System menu item.)* Opens the standard macOS share sheet for the saved world file. |
| **Page Setup…** | ⇧⌘P | Sets paper size, orientation, and margins for printing. |
| **Print…** | ⌘P | Prints the frontmost document. For a **world** window, prints session **output** as plain text (see [Printing](#printing) below). For a **text document**, prints the editor contents using the standard macOS print dialog. |

**Tips**

- The window title shows the document’s filename (without extension). A **— Edited** suffix means there are unsaved changes.
- Legacy Savitar 1 worlds open as **read-only**; save them as a Savitar 2 `.world` file to edit triggers, macros, and settings.
- **Duplicate** plus **Save** is the usual way to branch a world into two files. **Rename…** and **Move To…** adjust an existing saved file without creating a copy.

#### Text documents

Plain-text windows are separate from world sessions. Use them to view or edit log files, notes, or other text outside a live connection.

- **New Text Document** (⇧⌘T) opens an empty editor with a fixed-pitch font.
- **Open…** accepts `.txt`, `.text`, and `.log` files in addition to `.world` documents.
- Standard **Save**, **Duplicate**, **Print**, and **Edit** commands apply. Find uses the system find panel.
- Window position and size are remembered between launches (shared across all text document windows).
- Automatic session logging (configured in **World Settings → Output**) is separate: it writes world output to a file in the background without opening a text window.

#### Printing

**Print…** sends the **output pane** to the system print dialog—not the input line, and not styled ANSI colors.

- Text is printed in the world’s monospace font, one line per row, so ASCII art and MUD maps keep their shape.
- Colors from the session are not included; print and PDF output is black on white.
- Choose **PDF → Save as PDF** in the print dialog to save a PDF. The default filename is the **world’s name** (for example, `Alter Aeon.pdf`).

The in-game `@printsource` command is separate: it is a debug/logging action, not the same as **File → Print…**.

### Edit menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Undo** | ⌘Z | Undoes the last edit in the focused text field or Events editor. World settings changes made in **World Settings** are also undoable. |
| **Redo** | ⇧⌘Z | Re-applies the last undone edit. |
| **Clear Output** | ⌘K | Clears all text in the **output** pane of the frontmost **world** document. Disabled for plain-text document windows. |
| **New Trigger** / **New Macro** | ⇧⌘N | When an **Events** window is frontmost, adds a new trigger or macro depending on the active tab. The menu label changes automatically. Disabled when no Events window is key. |
| **Cut** | ⌘X | Cuts the selection in the focused text field (typically the input line or an Events editor field). |
| **Copy** | ⌘C | Copies the selection. Works in the input line, Events editors, and the output pane (when text is selected). |
| **Paste** | ⌘V | Pastes into the focused text field. |
| **Delete** | ⌫ | Deletes the selection in the focused text field. |
| **Select All** | ⌘A | Selects all text in the focused text field. |
| **Find…** | ⌘F | Opens find for the active pane (see [Find](#find) below). |
| **Find Next** | ⌘G | Jumps to the next match. |
| **Find Previous** | ⇧⌘G | Jumps to the previous match. |
| **Use Selection for Find** | ⌘E | Copies the current selection into the find string. |
| **Jump to Selection** | ⌘J | Scrolls the focused text view so the selection is visible. |
| **Speech → Speak Selected Text** | — | Speaks the selected text in the input or output pane. See the [Speech](#speech) chapter. |

#### Find

Find behavior depends on which pane is active in a world document:

| Active pane | Find UI | Notes |
|-------------|---------|-------|
| **Input** | Standard macOS find panel | Full keyboard navigation (⌘F, ⌘G, ⌘⇧G). |
| **Output** | Find bar above the output pane | Same menu commands; search runs in the session output (HTML content is searched as plain text). |

Find is available when a world document window is frontmost, or when any text view in the app has focus.

### World menu

Available when a **world document** window is frontmost.

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Enter Full Screen** | ⌃⌘F | Toggles full-screen mode for the world window. |
| **Show World Events…** | — | Opens the **Events** window for this world document—triggers and macros stored in the `.world` file. If the window is already open, brings it forward. The title includes the world document name. |
| **Show World Settings…** | ⇧⌘J | Opens the **World Settings** sheet for this world. See [World Settings](#world-settings) below. Click **OK** to apply or **Cancel** to discard. |
| **Scroll Lock** | ⌃S | Toggles **scroll lock** on the output pane. When on (checkmark shown), new text still arrives but the view does not auto-scroll to the bottom—useful for reading back while the session continues. Also available from the scroll-lock button in the window title bar. |

The same **World Settings** and **Events** commands are available from buttons in the world window’s title bar.

### Audio menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Mute Sound Cues** | — | Toggles trigger **sound** effects on or off (checkmark when muted). Mirrors **Settings → Audio**. |
| **Mute Speaking Cues** | — | Toggles all **spoken** output—trigger speech and continuous speech (checkmark when muted). Mirrors **Settings → Audio**. |
| **Flush Speech Buffer** | ⌘L | Stops speech immediately and discards queued utterances. Enabled only while Savitar is speaking. |
| **Speech Settings…** | — | Opens **Settings → Speech** (continuous speech, voice, and rate). |

Full detail is in the [Speech](#speech) chapter.

### Window menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Minimize** | ⌘M | Minimizes the frontmost window to the Dock. |
| **Zoom** | — | Toggles the window between its user size and a larger size that fits content. |
| **Bring All to Front** | — | Brings all Savitar windows above windows from other apps. |
| *(document list)* | — | Lists open Savitar windows; select one to bring it forward. |
| **Show App-wide Events Window** | ⇧⌘E | Opens the **app-wide Events** window for universal triggers and macros (imported from Savitar 1 preferences). Separate from per-world **Show World Events…**. |

### Help menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Savitar Help** | ⌘? | Opens in-app help when a help book is installed. Until Help ships, this may have limited content; use this user guide and [docs/USER_GUIDE.md](USER_GUIDE.md) in the repository. |

---

## Events

In Savitar, an **event** is anything the client does **automatically** on your behalf during a session—beyond simply showing server text and forwarding what you type. Events are how Savitar **reacts** to the game and **extends** your keyboard.

Most players think of two kinds:

| Kind | You define it to… | Typical example |
|------|-------------------|-----------------|
| **Trigger** | Run when matching **text** appears in output (or input) | Play a chime when “You feel hungry” arrives; gag a spammy line; send a reply when the MUD prompts you |
| **Macro** | Run when you press a **hotkey** | Send `cast heal` on F5 instead of typing it |

Triggers are **reactive**—they fire when something happens in the session. Macros are **initiated by you**—but both are edited in the same place and stored the same way, so Savitar groups them under one name: **events**.

### The Events window

You manage events in an **Events** window:

- **Per-world** — **World → Show World Events…** (or the events button in the world window title bar). Triggers and macros here are saved in that world’s `.world` document.
- **App-wide** — **Window → Show App-wide Events Window** (⇧⌘E). Triggers and macros here apply to **every** world—useful for universal gags, sounds, or shortcuts you always want. Imported from Savitar 1 preferences.

Each Events window has two tabs: **Triggers** and **Macros**. Select an item in the list to edit it in the detail pane (matching rules, colors, audio cues, replies, hotkeys, and so on).

When an Events window is frontmost, **Edit → New Trigger** or **New Macro** (⇧⌘N) adds an item to the active tab.

### Why “event”?

The word predates Savitar 2—it is Savitar 1’s name for this whole family of behaviors. It is **not** a generic programming term in the UI; you will not configure “events” separately from triggers and macros. If you see **Events** in a menu or window title, read it as **triggers and macros for this world (or for the whole app)**.

See [Macros](#macros) below for hotkey commands. A full **Triggers** chapter (matching, gags, audio, replies, variables) is planned in [Story 9](Stories.md).

---

## Macros

A **macro** in Savitar is not like a spreadsheet macro. It is a **keyboard shortcut that sends a command** to the game—one keypress instead of typing the same line over and over.

### Example

Suppose you play **Alter Aeon** and often type `cast heal`. You can create a macro whose **value** is `cast heal` and assign a **hotkey** such as **F5**. Press F5 while connected and Savitar sends that line to the world as if you had typed it and pressed Return.

The same idea works for common MUD commands:

| You might macro… | Value (command sent) |
|------------------|----------------------|
| Heal | `cast heal` |
| Look around | `look` |
| Go north | `n` |
| Rest | `rest` |
| A custom emote | `wave` |

Macros are for the repetitive stuff—the commands you use dozens of times per session.

### Where macros live

- **Per-world macros** — stored in the `.world` document. Open **World → Show World Events…** and select the **Macros** tab.
- **App-wide macros** — shared across all worlds (imported from Savitar 1 preferences). Open **Window → Show App-wide Events Window** and use the **Macros** tab there.

Each macro has a **name** (for your reference in the list), a **value** (the text sent to the game), and an optional **hotkey**. You can enable or disable macros without deleting them.

To add one quickly: bring an Events window forward and choose **Edit → New Macro** (⇧⌘N when the Macros tab is active).

### Macros vs other Savitar features

See [Events](#events) for the big picture. In short:

| Feature | What it does |
|---------|----------------|
| **Macro** | Hotkey sends a fixed command you define |
| **Trigger** | Watches **output** (or input) and reacts when text matches a pattern |
| **Trigger variable** | Scratch space triggers write into (for captured text), not a hotkey command |

Savitar 1’s **Macro Clicker** used **aliases**—on-screen buttons that pointed at macros. That clicker window is not in Savitar 2 yet; macros themselves work via hotkeys.

---

## World Settings

**World Settings** holds options for the **active world document**—connection details, fonts and colors, input behavior, and logging. Open it with **World → Show World Settings…** (⇧⌘J) or the settings button in the world window title bar.

Changes are staged in the sheet until you click **OK** (or **Cancel** to discard). World settings edits are **undoable** (⌘Z) like other document changes.

### Tabs

| Tab | Purpose |
|-----|---------|
| **Starting** | Host, port, retry/keepalive, startup commands |
| **Appearance** | Colors, body/code fonts, ANSI and HTML interpretation |
| **Input** | Echo, sticky commands, markers, line ending |
| **Output** | Session logging to a file |

Other v1 tabs (**MCP**, **Closing**) are not in Savitar 2 yet; see the [README](../README.md) parity checklist.

### Input tab

Controls how Savitar handles what you type and how commands are sent to the server.

#### Input echoing

Choose whether typed input is copied into the **output** pane:

| Option | Behavior |
|--------|----------|
| **No echo** | Input is sent to the server only; nothing is shown locally |
| **Echo carriage return only** | Only a line break appears in output when you press Return |
| **Echo all input** | The full command line is shown in output before it is sent |

This matches Savitar 1’s echo settings.

#### Sticky commands

When **Sticky commands** is checked, pressing Return after a command **leaves the text selected** in the input line instead of clearing it. Type over the selection or press ↑/↓ to recall history as usual. Useful when you send the same command repeatedly with small edits.

#### Markers

Markers are short strings Savitar recognizes in commands, triggers, and macros. Defaults match Savitar 1:

| Marker | Default | Used for |
|--------|---------|----------|
| **Command** | `##` | [Local commands](http://heynow.com/savitar/manual140/_mancontent6.html) (handled by Savitar, not sent to the server) |
| **Variable** | `%%` | Expanding scratch values (for example `say %%name`) and trigger-set variables |
| **Wildcard** | `$$` | Wildcard patterns in trigger names (for example `tell $$target`) |

You can change any marker per world. Use a string that will not appear in normal game text. Empty markers disable that feature.

#### Line ending

Choose what Savitar appends when a command is sent (including an empty Return):

| Option | Sent bytes | Typical use |
|--------|------------|-------------|
| **Carriage return only (CR)** | `\r` | Many MUDs and older telnet hosts |
| **Carriage return + line feed (CR/LF)** | `\r\n` | Default; common on Windows-oriented servers |

Savitar 1 called this **CROnly** in world files (`FLAGS="…+CROnly"`). Worlds imported from v1 keep their line-ending preference.

**Tip:** If commands seem ignored or the host reports “unknown command” with extra characters, try switching line ending—wrong CR/LF is a common connection troubleshooting step (see [Story 9.6](Stories.md)).

### Output tab

| Control | Description |
|---------|-------------|
| **Logging Enabled** | When on, Savitar writes session output to a log file in the background |
| **Append / Overwrite** | Whether each session adds to the file or replaces it |
| **Log file path** | Where the log is stored; use **Set now** to pick a location |

Session logging is separate from **text document** windows and from **File → Print…**. See [Text documents](#text-documents) under the File menu.

---

## Privacy & usage statistics

Official Savitar builds from Heynow Software send **anonymous usage statistics** to help measure active installations and version adoption. We use [TelemetryDeck](https://telemetrydeck.com/), a privacy-first analytics service: signals include app version, build number, and macOS version only — **no account names, world names, session text, or other personal data**.

Each installation uses a hashed identifier; TelemetryDeck does not receive your name, email, or IP address in a form that identifies you. You can read more in [TelemetryDeck's privacy policy](https://telemetrydeck.com/privacy/).

Local development builds, unit tests, and builds you compile from source **do not** send analytics unless you configure a TelemetryDeck App ID yourself.

---

## Getting help

1. **Savitar Help** — **Help → Savitar Help** (⌘?) opens this guide inside the app (works offline).
2. **Release notes** — **Help → Release Notes…** lists recent changes on the web.
3. **Send Feedback** — *(coming in a future update)* email the Savitar team with problems or feature ideas. You will not need a GitHub account.
4. **Web guide** — the latest draft of this guide is also in the [Savitar 2 repository](https://github.com/jkoutavas/Savitar2/blob/master/docs/USER_GUIDE.md).

Before reporting a problem, check the relevant chapter here (triggers, speech, world settings). Include your Savitar version and macOS version when you contact support.

---

## More chapters (planned)

Story 9 in [Stories.md](Stories.md) maps the [Savitar 1.4 User's Manual](http://heynow.com/savitar/manual140.html) to remaining guide chapters. Suggested next writes: **Getting started** (9.1), **Session window** (9.2), **Triggers in depth** (9.4), then **Worlds & connection** (9.6). World Settings **Starting** and **Appearance** tabs are covered briefly in [World Settings](#world-settings); fuller reference is **9.5**.
