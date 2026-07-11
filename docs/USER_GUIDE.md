# Savitar 2 User Guide

_Last updated July 11, 2026._

This guide explains how to use Savitar 2. It is written for **players and world builders**, not developers. See [Stories.md](Stories.md) **Story 9** for chapters still in progress.

If you are upgrading from Savitar 1, see [Migrating from Savitar 1](#migrating-from-savitar-1) for import behavior and menu or settings changes.

**A note from Savitar's author, Jay "Ktown" Koutavas.**

*Savitar has been my labor of love for Mac MUD players since 1996. For you old timers, version 2 carries your worlds, triggers, and habits forward after the 32-bit era ended. And those just getting started with Savitar, Welcome! Use this guide when you're stuck—then tell me what still doesn't feel like Savitar. Help → Send Feedback… is the fastest way.*

*May you have many exciting stories to share, adventurer!*

---

## Getting started

### What is Savitar?

**Savitar** is a **Macintosh client for MUDs, MUSHes, MOOs, and other telnet text worlds**—the kind of games and communities you connect to over the internet and play by typing commands.

Savitar helps you:

- **Connect** to one or more worlds at once
- **Automate** repetitive play with triggers (react to server text) and macros (hotkey commands)
- **Read and hear** session output—with ANSI colors, optional HTML, and speech

Savitar 2 is a **64-bit rewrite** of Savitar 1.6.x for modern macOS. Your triggers, macros, worlds, and preferences can migrate from v1; see [Migrating from Savitar 1](#migrating-from-savitar-1) below.

For the story behind the rewrite, see [JOURNEY.md](JOURNEY.md) in the repository—not required reading to play.

### System requirements

| Requirement | Detail |
|-------------|--------|
| **macOS** | **10.12 (Sierra)** or later for Savitar 2 |
| **Savitar 1** | Runs only on **32-bit** macOS through **10.14 Mojave**. It does **not** run on **Catalina (10.15)** or later—that is why Savitar 2 exists |
| **Network** | TCP connection to your world's host and port (typical MUD ports: 3000, 4000, 23) |
| **Speech** | Optional; continuous speech requires **macOS 10.15+** and an English voice installed |

Official builds are **free downloads** from [GitHub Releases](https://github.com/jkoutavas/Savitar2/releases). Savitar is open source; you may also build from source for your own use.

### Quick start

1. **Launch Savitar** and open the **World Picker** (at startup by default, or **File → New World Document…**).
2. **Double-click a world** (for example Alter Aeon) to open a session window and connect.
3. Type a command in the **input** pane at the bottom and press **Return**.
4. Open the **Events** window (**World → Show World Events…**) to add triggers or macros.

The session window has separate **output** (top) and **input** (bottom) panes. Resize them by dragging the window corner or the split divider—see [Session window](#session-window).

**Tip:** Open **Help → Savitar Help** (⌘?) anytime to return to this guide offline.

**Contextual help:** Major windows show a **?** that opens this guide to the relevant section — **World Picker**, **world session window**, **Events**, **Settings** (per toolbar pane), and **World Settings** (per tab, top-right of the sheet).

### Migrating from Savitar 1

If you used Savitar 1 on an older Mac:

| Topic | Savitar 2 behavior |
|-------|-------------------|
| **Preferences** | On first launch, Savitar 2 imports your v1 **preferences XML** (triggers, macros, colors, flags) when it finds a Savitar 1 prefs file |
| **World files** | Open legacy `.world` documents; they are **read-only** until you **Save** as a Savitar 2 world |
| **Universal events** | v1 "universal" triggers and macros appear in **Window → Show App-wide Events Window** (⇧⌘E) |
| **Menus** | **Edit → Speech → Speak Selected Text** replaces v1 **Start Speaking**; **Audio → Flush Speech Buffer** (⌘L) clears queued speech |
| **Settings** | Scattered v1 preference dialogs are now **Settings…** (⌘,) toolbar panes—see [Settings reference](#settings-reference) |

Features **not in Savitar 2 yet** (but planned): command **aliases** (Story 10, 2.1), MCP SimpleEdit. **`##tell application`** (AppleScript) is not planned. The guide marks these where relevant.

---

## Install & updates

### Download and install

1. Open [Savitar 2 Releases](https://github.com/jkoutavas/Savitar2/releases) and download **Savitar.zip** from the latest release.
2. Unzip and drag **Savitar.app** to **Applications** (or another folder you use for apps).
3. On first open, macOS may ask you to confirm the app is from an identified developer—official builds are Developer ID signed and notarized.

There is no Classic Mac OS installer. **Uninstall** = quit Savitar and move **Savitar.app** to the Trash. Your worlds and preferences remain in your home folder.

### First launch

- If **Show World Picker at startup** is on (default), the World Picker opens automatically—see [Startup](#startup).
- Savitar 2 may show a **one-time welcome** during alpha testing explaining feedback and what to expect.
- Importing v1 preferences happens automatically when a v1 prefs file is present; you do not need a separate import step.

### Updates

Savitar checks for updates with **Sparkle**. See the [Updates](#updates) chapter for automatic vs manual checks and **Help → Release Notes…**.

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
- Continuous speech uses the **voice** and **rate** from app Speech settings (see below). These are **global** app preferences—not per-world settings.
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

Each trigger can use its own voice. The speech **rate** slider in Speech settings applies to trigger speech as well.

Trigger speech respects the same mute flags as continuous speech:

- **Mute Sound Cues** — suppresses trigger sounds only
- **Mute Speaking Cues** — suppresses trigger speech and continuous speech

### Edit → Speech

| Menu item | What it does |
|-----------|--------------|
| **Speak Selected Text** | Speak the selected text in the **input** or **output** pane (enabled when the active pane has a selection, or when the output pane is focused) |

Select text in either pane, then choose **Edit → Speech → Speak Selected Text**. Savitar speaks the selection using the voice engine configured in **Settings → Speech**.

### Audio menu

| Menu item | What it does |
|-----------|--------------|
| **Mute Sound Cues** | Toggle trigger sound effects on/off |
| **Mute Speaking Cues** | Toggle all spoken output (triggers + continuous speech) |
| **Flush Speech Buffer** (⌘L) | Stop speech immediately and discard queued utterances (enabled only while speech is active) |
| **Speech Settings…** | Opens **Settings → Speech** |

**Speech menu locations**

| Command | Menu | Purpose |
|---------|------|---------|
| **Speak Selected Text** | **Edit → Speech** | Read selected text in input or output |
| **Flush Speech Buffer** (⌘L) | **Audio** | Stop Savitar speech and clear its queue (continuous + trigger speech) |

If you used Savitar 1: **Start Speaking** is now **Speak Selected Text** under **Edit → Speech**; queued speech is cleared with **Flush Speech Buffer** (⌘L), not a separate Stop Speaking command.

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

## ANSI colors

MUDs and telnet hosts send **ANSI escape codes** to color and style text in the **output** pane. Savitar maps those codes to colors using a **global palette** of 24 swatches, edited in **Settings → Colors**.

### Opening the Colors pane

1. Open **Settings…** (⌘,) and select the **Colors** toolbar tab, or
2. Choose **Edit → ANSI Colors…**

Changes apply immediately to every open world window; you do not need to reconnect.

### The color grid

The pane shows **eight hues** (black through white) across **three shades** each:

| Shade | Role |
|-------|------|
| **Normal** | Standard foreground/background for that hue |
| **Dim** | Lighter or muted variant (ANSI “dim” / faint) |
| **Intense** | Bold or highlighted variant (ANSI bold or bright) |

Click any swatch to pick a new color. Use **Restore Defaults** to reset all 24 colors to Savitar’s built-in palette.

Color edits in Settings are **undoable** (⌘Z) like other preference changes. Your palette is saved in app preferences and survives relaunch; importing Savitar 1 preferences brings across your v1 ANSI colors.

### Colors vs World Settings → Appearance

| | **Settings → Colors** | **World Settings → Appearance** |
|--|------------------------|----------------------------------|
| Scope | **App-wide** — all worlds share the same ANSI palette | **Per world** — fonts, default fore/back colors, HTML/ANSI interpretation for that document |
| Use when | ANSI colors look wrong everywhere, or you want a custom theme | One world needs different fonts or base colors |

Speech and printing strip or ignore ANSI styling: continuous speech reads plain text, and **File → Print…** outputs black on white. See [Speech](#speech) and [Printing](#printing) under the File menu.

---

## Input & Display

Open **Settings…** (⌘,) and select the **Input & Display** toolbar tab. These options apply **app-wide** and save immediately.

### App appearance vs world appearance

| | **Settings → Input & Display** | **World Settings → Appearance** |
|--|-------------------------------|----------------------------------|
| **Scope** | App windows and dialogs (World Picker, Settings, Events, menus) | One connected world’s session output |
| **Controls** | **System** / **Light** / **Dark** popup | Fore/back colors, fonts, ANSI interpretation |
| **ANSI palette** | Unchanged — see [ANSI colors](#ansi-colors) | Unchanged |

**App appearance** is a Savitar 2-only preference (no Savitar 1 import). **System** follows macOS light/dark, including Auto sunrise/sunset. **Savitar Help** (⌘?) uses the same appearance for its content; world session output colors are unchanged.

| Option | What it does |
|--------|----------------|
| **App appearance** | **System** follows macOS; **Light** or **Dark** forces app chrome regardless of system setting. Does not change MUD session colors in world windows. |
| **Use keypad for macro entry** | When on, the numeric **keypad** can be used when assigning or firing **macro** hotkeys (for example `KP8`). When off, keypad keys are ignored for macros—useful if another app or the system uses the keypad differently. |
| **Mono fonts only (in font menus)** | When on, font pop-up menus in **World Settings → Appearance** list **monospace** faces only—handy for MUD sessions where fixed-width fonts keep columns aligned. |
| **Default word wrap for new sessions** | When on, new world sessions start with word wrap in the **input** and **output** panes. Long lines wrap to the pane width instead of scrolling horizontally. Does not change wrap on sessions already open. |

Macro hotkeys are edited in the **Events** window; see [Macros](#macros). Per-world fonts and colors are in [World Settings](#world-settings).

---

## Audio

Open **Settings…** (⌘,) and select the **Audio** toolbar tab. These mute flags apply **app-wide** and save immediately. The same two cue toggles are available from the menu bar **Audio** menu while a session is open—Settings and the menu stay in sync.

| Option | What it does |
|--------|----------------|
| **Mute sound cues** | Suppresses **trigger sound** effects (chimes and custom sounds configured in the Events window). Trigger **speech** is not affected. |
| **Mute speaking cues** | Suppresses all **spoken** output—trigger speech and **continuous speech**. If nothing is being read aloud, check this first. |
| **Mute clicker sounds** | Mutes the click sound when you press a **Macro Clicker** button (Settings → Audio). |
| **Mute terminal bell** | Suppresses the system beep when the server sends a telnet **bell** character (ASCII BEL). The character is still removed from output text; only the sound is skipped. |

**Speech** voice and rate live on the separate **Speech** settings pane—see [Speech settings reference](#speech-speech-settings-reference). To stop speech that is already playing, use **Audio → Flush Speech Buffer** (⌘L) from the menu bar.

---

## Updates

Official Savitar builds check for newer versions using [Sparkle](https://sparkle-project.org/). Open **Settings…** (⌘,) and select the **Updates** toolbar tab.

| Option | What it does |
|--------|----------------|
| **Check for updates automatically** | When on, Savitar periodically looks for a newer signed release in the background and can notify you when one is available. When off, you can still check manually. |

To check on demand, choose **Savitar → Check for Updates…** from the menu bar. If an update is available, Sparkle shows release notes (from the project changelog) and walks you through download and install.

**Help → Release Notes…** opens a web page with version history without running an update check—useful when you want to see what changed in past releases.

Automatic updates apply to **official signed builds** distributed by Heynow Software. Builds you compile from source in Xcode typically do not receive Sparkle updates through this channel.

Your automatic-update preference is saved in app preferences and survives relaunch.

---

## Startup

Open **Settings…** (⌘,) and select the **Startup** toolbar tab. These options control what Savitar opens when you launch the app.

| Option | What it does |
|--------|----------------|
| **Show World Picker at startup** | Opens the World Picker window when Savitar launches (default **on**). Turn off if you prefer to open worlds only via **File → Open…** or recent documents. |
| **Show Events Window at startup** | Opens the **app-wide Events** window (⇧⌘E) automatically. Useful if you live in universal triggers and macros. |
| **Show Macro Clicker at startup** | Opens the **Macro Clicker** palette when Savitar launches (see [Macros](#macros)). |

Startup flags save immediately like other app Settings. They do not affect worlds already open from a previous session—only the next launch.

---

## Advanced

Open **Settings…** (⌘,) and select the **Advanced** toolbar tab for rare maintenance actions.

### Restore Factory Defaults

**Restore Factory Defaults…** replaces all app settings with the configuration Savitar shipped with:

- Startup, input, audio, updates, and speech preferences
- World Picker world list and connection addresses
- App-wide triggers and macros
- ANSI color palette
- Saved positions for utility windows (World Picker, Events)

Your saved **`.world` documents on disk are not deleted**. Savitar asks for confirmation before restoring.

Use this when prefs feel corrupted, you want the bundled world list back, or you need a clean slate without reinstalling.

**Planned for Advanced** (not shipped yet): import/export preferences, re-import Savitar 1 preferences — see [Stories.md](Stories.md#story-24--settings-advanced-maintenance).

---

## Menus

Savitar’s menu bar follows standard macOS conventions. A few items are Savitar-specific; others are provided by the system because Savitar is a document-based app. On recent macOS versions, **File** may show additional items (such as **Duplicate**, **Rename…**, and **Move To…**) that replace or supplement older template entries—the behavior described here matches what you see at runtime.

World document windows, the **World Picker**, and the **Events** windows each enable the commands that apply to the frontmost window.

### Savitar menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **About Savitar** | — | Shows the About box with the classic medallion, version info, and scrolling credits (“Special Heynows”). Click anywhere (or press Escape) to dismiss. |
| **Check for Updates…** | — | Looks for a newer Savitar release (Sparkle). See [Updates](#updates). |
| **Settings…** | ⌘, | Opens the app **Settings** window (toolbar panes: Startup, Input & Display, **Colors**, Audio, Updates, Speech, **Advanced**). Changes apply immediately; there is no Save button. |
| **Services** | — | Standard macOS Services submenu for the current selection (when a supporting service is installed). |
| **Hide Savitar** | ⌘H | Hides all Savitar windows. |
| **Hide Others** | ⌥⌘H | Hides every app except Savitar. |
| **Show All** | — | Un-hides other applications. |
| **Quit Savitar** | ⌘Q | Quits the app. Open world documents are closed according to each window’s save state. |

See [Speech settings reference](#speech-speech-settings-reference) for **Speech**, [ANSI colors](#ansi-colors) for **Colors**, [Input & Display](#input-display), [Audio](#audio), [Updates](#updates), and [Advanced](#advanced) for the other Settings toolbar panes.

### File menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **New World Document…** | ⌘N | Opens the **World Picker** so you can choose a world to connect to. Double-clicking a world opens a new session in an untitled document window. |
| **New Text Document** | ⇧⌘T | Opens a new plain-text editor window for notes, logs, or other `.txt` / `.text` / `.log` files. |
| **Open…** | ⌘O | Opens a saved `.world` document or a plain-text file (`.txt`, `.text`, `.log`). Savitar reads Savitar 2 and legacy Savitar 1 world files. |
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
| **Show World Picker** | — | Opens the **World Picker**, or brings it forward if already open. Same result as **File → New World Document…** (⌘N)—handy for reopening the picker after you close it. |
| **Show App-wide Events Window** | ⇧⌘E | Opens the **app-wide Events** window for universal triggers and macros. Separate from per-world **Show World Events…**. |

Savitar does not use window tabs, so the Window menu has no **Show Tab Bar** or **Merge All Windows** items.

### Help menu

| Menu item | Shortcut | What it does |
|-----------|----------|--------------|
| **Savitar Help** | ⌘? | Opens this user guide in a Savitar window (works offline). |
| **Savitar Guide on the Web…** | — | Opens the latest draft of this guide on GitHub. |
| **Send Feedback…** | — | Opens your email app with a pre-filled message to the Savitar team (version info included). No GitHub account needed. |
| **About Privacy…** | — | Opens the [Privacy & usage statistics](#privacy) chapter in Savitar Help (TelemetryDeck analytics; no session text). See also [Privacy on the web](https://www.heynow.com/savitar/privacy.html). |
| **Release Notes…** | — | Opens the GitHub releases page with version history. |

---

## Session window

A **world document** window is your live connection to a MUD or telnet host. It has two panes:

| Pane | Purpose |
|------|---------|
| **Output** (top) | Server text, ANSI colors, and (optionally) echoed commands |
| **Input** (bottom) | The command line where you type; press **Return** to send |

Both panes are measured in monospace **columns** (width) and **rows** (height). The default for a new world is **80 columns × 24 output rows × 2 input rows**.

When you connect, Savitar prints a short **Welcome to Savitar** banner at the top of the output pane (version, website link, and a hint to type `##help` for local commands)—the same tradition as Savitar 1.

### Resizing panes

You can change pane size in three ways:

1. **Drag the window** — Use the resize control at the lower-right corner of the window. While you drag, a small yellow label shows the current output size as **rows×columns** (for example `24×80`).
2. **Drag the split divider** — Drag the bar between the output and input panes up or down to give more rows to one pane and fewer to the other. The yellow label appears here too.
3. **World Settings** — Enter exact values on **World Settings → Output** (columns and output rows) and **Input** (input rows), then click **OK**. See [World Settings](#world-settings).

Savitar saves the size in your `.world` document (`RESOLUTION` in the XML). The next time you open that world, the window restores to the saved dimensions.

**Tips**

- Sizes are most accurate with a **monospace** font (see **World Settings → Appearance**). Proportional fonts make row/column counts approximate.
- **Default word wrap** (Settings → Input & Display) affects how long lines behave inside the pane width; it does not change the column count.
- **Scroll lock** (⌃S or the title-bar lock button) stops the output pane from auto-scrolling when new text arrives. See the [World menu](#world-menu) table.

### Navigating output

The **output** pane is a web view showing styled session text. You can:

| Action | How |
|--------|-----|
| **Scroll** | Trackpad, mouse wheel, or scrollbar |
| **Scroll lock** | **World → Scroll Lock** (⌃S) or the lock button in the title bar—new text still arrives but the view does not jump to the bottom |
| **Select & copy** | Drag to select; **Edit → Copy** (⌘C) |
| **Clear** | **Edit → Clear Output** (⌘K) |
| **Find** | **Edit → Find…** (⌘F) when the output pane is active—see [Find](#find) under Edit menu |
| **Speak selection** | **Edit → Speech → Speak Selected Text** |

### Status bars

Each pane (output and input) can show a one-line **status bar** at its top—a strip of text you choose, set with [local commands](#local-commands) or from a trigger reply:

```text
##set status output You are fighting: %%opponent
##set status input HP: %%hitpoints
##close stats
```

`##set status` opens the bar if needed and replaces its current text; variables (`%%`) expand in the message. `##close stats` hides both bars; `##close status output` or `##close status input` hides one pane only. See [Local commands → Status bar commands](#local-commands).

Status bars render in **inverse** session colors—the strip uses the world's foreground color as its background, and the text uses the background color—so they stand out from the panes. Bars are per-session: they are not saved in the world document.

Configurable status bar styling (match session colors, or custom colors) is planned for **2.1**.

### Connection indicator

The session window title area shows connection state (connecting, connected, retrying). If a host is unreachable, Savitar retries according to **World Settings → Starting → Retry Seconds**. Closing the window disconnects the session; if **World Settings → Closing** has a logoff command configured, Savitar sends it to the world first.

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
- **App-wide** — **Window → Show App-wide Events Window** (⇧⌘E). Triggers and macros here apply to **every** world—useful for universal gags, sounds, or shortcuts you always want. Stored in app preferences.

Each Events window has two tabs: **Triggers** and **Macros**. The left side lists items in a table (440pt wide—all columns visible); the right side is the detail editor for the selected trigger or macro. There is no draggable split divider—the window is a fixed 900×400 utility panel, so column widths are tuned for that size. Events windows are **close-only** (no resize or minimize); Savitar remembers their position between sessions.

When an Events window is frontmost, **Edit → New Trigger** or **New Macro** (⇧⌘N) adds an item to the active tab.

### Why “event”?

In Savitar, **event** is the umbrella term for **triggers and macros together**—anything the client does automatically on your behalf during a session. It is **not** a generic programming term in the UI; you will not configure “events” separately from triggers and macros. If you see **Events** in a menu or window title, read it as **triggers and macros for this world (or for the whole app)**.

See [Macros](#macros) below for hotkey commands. Full trigger detail is in [Triggers](#triggers) below.

### Editing events

The Events window is where you create and maintain triggers and macros:

| Action | How |
|--------|-----|
| **New item** | **Edit → New Trigger** or **New Macro** (⇧⌘N) when an Events window is frontmost—the label matches the active tab |
| **Rename** | Click the name in the list and type (in-place editing) |
| **Reorder** | Drag items in the list to change processing order (**triggers**—order matters; see [Triggers](#triggers)) |
| **Enable / disable** | Checkbox in the list |
| **Undo** | ⌘Z after edits in detail fields |

**Per-world** vs **app-wide** windows are separate lists—see [The Events window](#the-events-window) above. Changes to a world document's events are saved with **File → Save** (⌘S).

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
- **App-wide macros** — shared across all worlds; stored in app preferences. Open **Window → Show App-wide Events Window** and use the **Macros** tab there.

Each macro has a **name** (for your reference in the list), a **value** (the text sent to the game), and an optional **hotkey**. You can enable or disable macros without deleting them.

To add one quickly: bring an Events window forward and choose **Edit → New Macro** (⇧⌘N when the Macros tab is active).

### Macros vs other Savitar features

See [Events](#events) for the big picture. In short:

| Feature | What it does |
|---------|----------------|
| **Macro** | Hotkey sends a fixed command you define |
| **Trigger** | Watches **output** (or input) and reacts when text matches a pattern |
| **Trigger variable** | Scratch space triggers write into (for captured text), not a hotkey command |

### Macro Clicker

The **Macro Clicker** is a floating palette of quick-access buttons—distinct from typed command **aliases** (abbreviations like `n` → `go north`), which are planned for Savitar 2.1. See [Glossary](#glossary). It has a periwinkle compass rose, green up/down arrows, and a 3×5 grid of chunky green-outlined labels (**1–9** and **a–f**). Every grid cell is a button bound to a **macro name**; clicking sends that macro’s value to the **frontmost world session**.

**Default macro names** use underscores throughout: grid slots **1–9** → `MACRO_1` … `MACRO_9`; **a–f** → `MACRO_A` … `MACRO_F`; compass directions → `MACRO_NORTH`, `MACRO_EAST`, and so on. Names must match **exactly**—`MACRO_1` and `MACRO-1` are different macros. When importing Savitar 1 preferences, legacy `ALIAS` bindings load; the **a** slot may retain a saved `MACRO_10` binding.

**World vs app-wide macros:** Each clicker button looks up its bound name in the **frontmost world** first (including macros you have just added in that world’s Events window, even before you save the document). If the world has no macro with that name, Savitar falls back to the matching **app-wide** macro. To override a universal macro for one world, create a world macro with the **same name**—for example, a world `MACRO_1` replaces the universal `MACRO_1` while that world is frontmost.

| Action | Result |
|--------|--------|
| **Click** a button | Send the bound macro to the active session |
| **Hover** a button | Caption shows the macro’s command text (or “Button not defined”) |
| **⌘-click** a button | Choose which **app-wide** macro name this button uses (stored in app preferences) |
| **Window → Show Macro Clicker** | Open or bring forward the palette |

Bindings are stored in app preferences as `ALIAS` XML (`NAME` → macro name). Factory defaults point direction buttons at `MACRO_NORTH`, `MACRO_EAST`, and so on—the same names as the bundled keypad macros. Early Savitar 2 builds that used hyphenated letter names (`MACRO-A` … `MACRO-F`) are upgraded to underscores when preferences load.

**Settings → Startup → Show Macro Clicker at startup** opens the palette at launch. **Settings → Audio → Mute clicker sounds** silences the button click cue.

---

## Entering commands

The **input** pane is a single-line (or few-row) command editor. What you type is sent to the server when you press **Return**—unless Savitar intercepts it as a **local command** or an **input trigger**.

### Sending lines

| Key / action | Result |
|--------------|--------|
| **Return** | Send the current line (with world line-ending postfix—see [World Settings → Input](#input-tab)) |
| **Return** on empty line | Sends only the line ending (useful for worlds that treat a blank line specially) |
| **⌥Return** (Option-Return) | Insert a newline **in the input field** without sending—useful when composing multi-line macros or startup scripts |

### Command recall

Savitar remembers up to **100** recent commands per session window.

| Key | Result |
|-----|--------|
| **↑** | Recall older commands |
| **↓** | Recall newer commands; at the bottom, clears to a fresh empty line |

Recall walks the history for **this session window** only. You can also pull a numbered entry with [`##recall`](#local-commands) and [`##history`](#local-commands).

### Input editing keys

These keys work in the input pane during a live session:

| Key | Action |
|-----|--------|
| **← / →** | Move cursor |
| **⌃A** | Beginning of line |
| **⌃C** | Send telnet **interrupt** (ASCII ETX)—some servers treat this as break/cancel |
| **⌃G** | Send telnet **bell** (ASCII BEL) |
| **⌃S** | Toggle **scroll lock** on output (not input editing) |

**Not yet implemented:** **⌃E** (end of line), **⌃U** (clear line), and **⌃W** (delete word) may return in a future update.

### Sticky commands

When **World Settings → Input → Sticky commands** is on, pressing Return **leaves your command selected** in the input line instead of clearing it—handy for repeating the same command with small edits. Press ↑/↓ to pull history as usual.

---

## Variables & expansion

Savitar can substitute **scratch variables** into commands, trigger replies, and macros before they are sent or executed.

### Syntax

Use your world's **variable marker** (default `%%`) followed by a name:

```text
say Hello, %%name!
```

When the command is processed, `%%name` is replaced with the current value stored for `name`. If no value exists, the marker may remain unchanged.

### Where values come from

| Source | Example |
|--------|---------|
| **Trigger wildcards** | A trigger pattern `tell $$target hello` captures `target` when it matches |
| **Trigger sets** | Triggers can write captured text into named variables for later replies |
| **Manual use** | You type `%%var` in macros, startup commands, or replies |

Variable markers are configured per world on **World Settings → Input → Markers**. The default is `%%`.

### Macros vs variables

| | **Macro** | **Variable (`%%name`)** |
|--|-----------|-------------------------|
| Fires when | You press a **hotkey** | Expanded whenever the text runs |
| Typical use | `F5` sends `cast heal` | `say %%target` uses last captured name |

See [Triggers](#triggers) for wildcards (`$$`) and regex captures.

---

## Local commands

**Local commands** are handled by Savitar—they are **not** sent to the game server. By default they start with the **command marker** `##` (configurable per world on **World Settings → Input**).

If the command marker is **empty**, local commands are disabled and all input goes to the server.

**Variable expansion:** Text you send—including trigger replies and macros—is expanded for `%%variables` *before* Savitar checks for a local command. So a macro or reply can run `##history` by expanding to the command marker plus `history`.

Examples below use the default `##` marker; substitute your world's marker if you changed it.

### Session and output

| Command | What it does |
|---------|----------------|
| `##history` | Prints a numbered list of recent commands for this session in the **output** pane |
| `##recall <n>` | Puts command *n* from that list into the **input** line (same numbers as `##history`) |
| `##!<n>` | Shorthand for `##recall <n>` — for example `##!3` recalls entry 3 |
| `##clear screen` | Clears the output pane (same as **Edit → Clear Output**, ⌘K) |
| `##link <url> "label" #RRGGBB` | Inserts a clickable hyperlink in the **output** pane (v1 syntax: angle brackets around the URL) |
| `##help` | HTML list of local commands by category; click a command for syntax and details |
| `##help <command>` | Detail for one command — for example `##help upload` |
| `##capture` | Toggles ad-hoc capture of session output to a plain-text file (save panel on start; run again to stop). The file path in the output pane is a link—click it to open the capture in a Savitar text window. |
| `##upload <file-path>` | Sends a local text file to the connected world as raw bytes (not parsed by Savitar). Use a POSIX path or `~`; quote paths with spaces. |

`##help` works even when **Interpret HTML tags** is off. Commands in the list are clickable (Pueblo-style `xch_cmd` links) and run `##help <command>` for you.

If you omit `"label"` on `##link`, the URL is used as the link text. If you omit `#color`, the world's **Link color** (World Settings → Appearance) is used. Web links open in your browser when clicked.

```text
##help
##help upload
##capture
##upload ~/scripts/login.txt
##upload "/Users/me/My Scripts/refresh.txt"
##link <https://www.heynow.com/savitar> "Savitar home"
##link <https://example.com> "Example" #FF6600
```

Example (`##history`):

```text
##history
```

Might show:

```text
[SAVITAR] Command history:
 1  look
 2  n
 3  cast heal
```

Then `##recall 2` or `##!2` puts `n` in the input line.

### Status bar commands

| Command | What it does |
|---------|----------------|
| `##set status output <message>` | Shows `<message>` in a one-line [status bar](#status-bars) at the top of the **output** pane (opens the bar if needed) |
| `##set status input <message>` | Same, for the **input** pane |
| `##close stats` | Hides **both** status bars |
| `##close status output` | Hides only the output-pane status bar |
| `##close status input` | Hides only the input-pane status bar |

Variables expand in status messages—`##set status input HP: %%hitpoints` from a trigger reply keeps a live readout on screen.

### World flags and markers

These change settings for the **current session's world** immediately (they are not saved until you save the world document):

| Command | What it does |
|---------|----------------|
| `##set ansi on` / `off` | Toggle ANSI color processing on output |
| `##set html on` / `off` | Toggle HTML output mode |
| `##set echo on` / `off` | Toggle command echo (show sent commands in output) |
| `##set cronly on` / `off` | Toggle CR-only line endings |
| `##set autoclose on` / `off` | Toggle auto-close when the server disconnects |
| `##set marker command <text>` | Set the local-command marker (up to 2 characters) |
| `##set marker macro <text>` | Set the variable marker (default `%%`) |
| `##set marker wildcard <text>` | Set the wildcard marker in trigger patterns (default `$$`) |
| `##set macro "<name>" <value>` | Set a **scratch variable** `<name>` to `<value>` (same as `%%name` expansion—not a macro hotkey in the Events window) |

### Triggers and macros

| Command | What it does |
|---------|----------------|
| `##enable trigger "<name>"` | Enables a world or app-wide trigger by name (`##enable trigger beep` works for one-word names) |
| `##disable trigger "<name>"` | Disables a trigger by name (same quoting rules as enable—use quotes when the name contains spaces) |
| `##add trigger <XML>` | Parses a `<TRIGGER …>` XML fragment and adds it to **this world's** Events list |
| `##add macro <XML>` | Parses a `<MACRO …>` XML fragment and adds it to **this world's** Events list |
| `##regex "<text>" "<pattern>"` | Tests a regular expression; prints match groups and stores them in scratch variables `%%0`, `%%1`, … for this session |

**Dump listings** (XML written to the output pane, pretty-printed):

| Command | What it does |
|---------|----------------|
| `##dump colors` | App-wide ANSI color definitions |
| `##dump macros` | App-wide and world macros |
| `##dump triggers` | App-wide and world triggers |
| `##dump worlds` | Worlds in the World Picker list |

Each listing is split into **universal** (app-wide) and **world specific** sections. An empty section shows `(none)`. Dump output is safe to read even when **HTML output** is on—the XML is escaped so tags are not swallowed by the WebKit pane.

**Developer debugging:**

| Command | What it does |
|---------|----------------|
| `##dump` | Prints the output pane's HTML source to the **Xcode/console log** (not the output pane) |

To copy a trigger or macro from one place to another, use `##dump triggers` or `##dump macros`, copy the XML block you need, then `##add trigger …` or `##add macro …`.

### Windows and sessions

| Command | What it does |
|---------|----------------|
| `##broadcast <command>` | Sends `<command>` to every **other** connected world session (not the one that ran the command) |
| `##select window "<title>"` | Brings the session window whose title **contains** `<title>` to the front |
| `##close window "<title>"` | Closes that window (same partial title match) |

Useful when you play several worlds at once and want one trigger reply to poke another session.

### Delays (`##wait`)

```text
##wait <seconds> [<command>]
```

Waits *seconds*, then runs `<command>` if you provided one. Used heavily in **trigger replies** to stagger auto-actions:

```text
##wait 2 look
##wait 5 cast heal
```

With no command, `##wait` alone does nothing visible—it is meant as part of a reply chain.

### Planned next (not in this release)

| Command | Notes |
|---------|--------|
| `##tell application` | AppleScript-era integration—not planned |

See [Stories.md](Stories.md) for the full v1 manual map and future work.

---

## Triggers

A **trigger** watches session text and **reacts** when a pattern matches. Triggers are the heart of Savitar automation—gags, highlights, sounds, auto-replies, and variable capture.

### Trigger types

| Type | Watches | Typical use |
|------|---------|-------------|
| **Output** | Text arriving from the server | Gag spam, play a sound on "You feel hungry", highlight guild chat |
| **Input** | Text you type before it is sent | Shortcuts that never reach the server, input-side patterns |

Configure type in the Events window detail pane.

### Processing order

When a line of text is processed:

1. **App-wide triggers** run first (from **Window → Show App-wide Events Window**), top to bottom in the list
2. **Per-world triggers** run next (from **World → Show World Events…**), top to bottom
3. Within each list, **gags** run first, then **substitution** triggers, then remaining matches

**Tip:** Put specific gags above broad patterns. If two triggers could match, order and trigger kind matter.

### Matching modes

In the trigger editor **Matching** tab:

| Mode | Matches when |
|------|----------------|
| **Contains** | The line includes the pattern text |
| **Starts with** | The line begins with the pattern |
| **Regular expression** | Pattern is a regex (power users) |

Additional flags (**exact**, **whole line**, **whole word**) refine matching.

### Wildcards (`$$`)

In trigger **names** (patterns), `$$` marks a **wildcard** that captures text into a variable. With default markers, `tell $$player hello` can capture `player` when the line matches.

Use captured values in replies with `%%player` (or your variable marker).

### Appearance (gags & color)

| Appearance | Effect |
|------------|--------|
| **Gag** | Matching text is removed from output (or input processing) |
| **Change appearance** | Recolor matching text using trigger style settings |
| **Don't use style** | Match only—used with audio or reply |

### Audio & reply

| Tab | Purpose |
|-----|---------|
| **Audio Cue** | Play a sound, speak the matched line, or speak fixed text |
| **Reply** | Automatically send a command to the server when matched (can include `%%variables`) |

Replies run through the same expansion and local-command handling as typed input. Audio respects **Audio** menu mute flags—see [Speech](#speech).

### Continuous speech interaction

When **continuous speech** is on, trigger speech and continuous speech share the speech queue. Use **Audio → Flush Speech Buffer** (⌘L) to skip ahead. See [Speech](#speech).

### Import & storage

- **Per-world triggers** live in the `.world` document—**File → Save** persists them.
- **Universal triggers** live in app preferences.
- Opening a v1 world **read-only** still lets you view events; save as v2 to edit.

---

## Output & appearance

This section supplements [World Settings → Appearance](#appearance-tab) and [ANSI colors](#ansi-colors).

### ANSI output

Most MUDs send **ANSI escape codes** for color. Savitar converts them to HTML in the output pane using your global palette (**Settings → Colors**). If colors look wrong:

1. Confirm **World Settings → Appearance → Interpret ANSI codes** is on
2. Tune palette colors in **Settings → Colors**
3. Check fore/back defaults on the Appearance tab for invisible combinations (white on white)

### HTML in output

When **Interpret HTML tags** is on, simple HTML in server text is rendered; **Code font** applies to `<code>` regions. **Pueblo `xch_cmd` links** (`<a xch_cmd="command">`) are clickable: the command is sent to the session (prefix with your local-command marker, e.g. `##help history`, for Savitar local commands). Normal `<a href="…">` links open in your browser.

### Word wrap

**Settings → Input & Display → Default word wrap for new sessions** sets the initial wrap state at connect time. Changing the pref does not affect already-open sessions. Per-session toggle and per-world default are planned (Story 20).

### Session logging

**World Settings → Output** can append or overwrite a log file on disk—separate from **File → Print…**, from **New Text Document** windows, and from ad-hoc **`##capture`**.

**`##capture`** toggles on-the-fly capture of session output to a plain-text file you choose in a save panel. Run **`##capture`** again to stop; Savitar confirms the file path in the output pane. Capture begins at the toggle point (earlier output is not retroactively written). The capture file uses the same plain-text rules as continuous logging: ANSI stripped, HTML reduced to readable text, Unix line endings.

See [Local commands → Session and output](#session-and-output) for syntax.

### Output scrollback (differences from Savitar 1)

Savitar 1 exposed output **buffer size** and **flush period** in World Settings. Savitar 2 **does not** offer these controls. At **beta**, Savitar will silently trim scrollback using imported `OUTPUTMAX` and `OUTPUTMIN` from each world file (defaults ~100KB / ~25KB); **flush period** (`FLUSHTICKS`) is not used. Output uses a `WKWebView` with internal optimizations documented for developers in [OutputPerformance.md](OutputPerformance.md).

If output feels laggy during very fast spam, use **Help → Send Feedback…** so we can profile scrollback behavior.

---

## Worlds & connection

### World Picker

The **World Picker** is Savitar’s front door — a modeless utility window listing worlds from your app preferences (bundled defaults, imported worlds, or ones you added).

| Action | How |
|--------|-----|
| **Connect** | Double-click a world, select one and press **Connect** or Return, or use the **Connect** button |
| **Add** | **Add…** opens the **World Wizard** (name, host, port) |
| **Remove** | Select a world and click **Remove** or press Delete |
| **Edit connection** | Open a session, then **World → Show World Settings…** (⇧⌘J) |

Each row shows the world name and `host:port`. The connection card below the list shows the full `telnet://` address for the selected world.

**Settings → Advanced → Restore Factory Defaults** resets the World Picker world list to Savitar’s bundled defaults without deleting your saved `.world` files.

Each **connection** opens a **world document window**—you can have multiple worlds open at once. Use the **Window** menu to switch.

### World documents

A `.world` file stores connection settings, triggers, macros, and layout. **File → Save** writes changes. **File → Duplicate** (⇧⌘S) branches a copy.

Legacy **Savitar 1 worlds** open read-only; use **Save** to write a Savitar 2 document.

### Connecting

On connect, Savitar:

1. Opens a TCP socket to **Host** / **Port** from **World Settings → Starting**
2. Runs **startup commands** (one per line) after a successful connect
3. Applies **Retry Seconds** and **Keepalive Minutes** from the Starting tab

### Troubleshooting connections

| Symptom | Things to try |
|---------|----------------|
| Commands ignored or doubled | Wrong **line ending**—toggle **CR** vs **CR/LF** on **World Settings → Input** |
| Immediate disconnect | Verify host/port; check firewall; try from another client |
| Idle timeout | Increase **Keepalive Minutes** on Starting tab |
| Garbled text | ANSI/HTML interpretation flags on Appearance tab |

---

## Settings reference

Quick map from **Savitar 1 preferences** dialogs to **Savitar 2** surfaces.

### App Settings (⌘,)

| Savitar 2 pane | v1 equivalent (approx.) |
|----------------|-------------------------|
| [Startup](#startup) | World Picker / Events / Clicker at launch |
| [Input & Display](#input-display) | App appearance (System / Light / Dark), keypad, mono fonts, default word wrap |
| [Colors](#ansi-colors) | ANSI Color Settings |
| [Audio](#audio) | Mute sound / speaking / bell / clicker |
| [Updates](#updates) | Check for updates |
| [Speech](#speech-speech-settings-reference) | Continuous speech, voice, rate |
| [Advanced](#advanced) | Restore factory defaults; import/export (planned) |

### World Settings sheet (⇧⌘J)

| Savitar 2 tab | v1 equivalent |
|---------------|---------------|
| [Starting](#starting-tab) | Starting tab |
| [Appearance](#appearance-tab) | Appearance tab |
| [Input](#input-tab) | Input tab |
| [Output](#output-tab) | Output tab |
| [Closing](#closing-tab) | Closing tab (logoff command) |
| *(missing)* | MCP — not in v2 yet |

Grayed-out app prefs are documented in [Settings reference](#settings-reference); Macro Clicker and Mute clicker are now active.

---

## Tips & troubleshooting

| Problem | Things to check |
|---------|-----------------|
| **No speech** | [Speech](#speech)—continuous enabled? **Mute Speaking Cues** off? macOS 10.15+? |
| **Trigger never fires** | List order; trigger enabled; correct **output vs input** type; pattern spelling |
| **Trigger fires too much** | Narrow match (whole line / regex); move gag above loose patterns |
| **Wrong colors** | [ANSI colors](#ansi-colors); Appearance fore/back; ANSI interpretation on |
| **Can't connect** | [Worlds & connection](#worlds--connection)—host, port, line ending |
| **MUX/MUSH marker conflicts** | Some worlds use `` ` `` for commands; Savitar default is `##`—change command marker in Input tab if local commands collide |
| **Laggy output on spam** | Long sessions fill the output pane — use **Help → Send Feedback…** with world name and what you were doing (combat spam, AFK, etc.) |

When in doubt: **Help → Savitar Help** (⌘?) for the chapter, then **Help → Send Feedback…** with version info included.

---

## Glossary

| Term | Meaning |
|------|---------|
| **ANSI** | Terminal color/style escape codes in server text |
| **App-wide events** | Triggers/macros stored in preferences and applied to every world |
| **Alias** | *(Planned.)* Typed abbreviation expanding to a command before send—distinct from macros |
| **Event** | Savitar's umbrella term for **triggers** and **macros** (see [Events](#events)) |
| **Gag** | Trigger appearance that hides matching text |
| **Local command** | `##command` handled by Savitar, not sent to the server (see [Local commands](#local-commands)) |
| **Macro** | Hotkey that sends a predefined command string |
| **MUD** | Multi-User Dungeon—a text multiplayer game accessed via telnet-like protocols |
| **MOO / MUSH** | Related text-world genres; Savitar connects to their servers like any telnet host |
| **MUVE** | Multi-User Virtual Environment—umbrella term (see heynow.com MUVE pages) |
| **Output pane** | Top pane showing server text |
| **Input pane** | Bottom pane where you type commands |
| **Trigger** | Pattern-driven automation on session text |
| **Variable (`%%`)** | Named scratch value expanded into commands and replies |
| **Wildcard (`$$`)** | Pattern placeholder in trigger names that captures text |
| **World** | A saved connection profile (host, port, events, settings) |
| **World document** | Open window representing one world session or saved `.world` file |

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
| **Closing** | Logoff command sent when closing a connected session |

The **MCP** settings tab is not in Savitar 2 yet; see the [README](../README.md) checklist.

### Starting tab

Connection and identity for **this world document**:

| Field | What it does |
|-------|----------------|
| **World Name** | Display name for the world (shown in the window title and lists). |
| **Host Name** | Server hostname or IP address to connect to. |
| **Host Port** | TCP port (for example `3000` for many MUDs). |
| **Retry Seconds** | How long to wait between connection retries after a failed connect (`0` = use Savitar’s default). |
| **Keepalive Minutes** | Interval for keepalive traffic on idle connections (`0` = off). Helps some hosts drop stale sessions less aggressively. |
| **Startup commands** | Commands sent automatically after a successful connect, one per line—often login name, password, or `look`. |

Changes apply when you click **OK** and take effect on the **next** connection to that world.

### Appearance tab

How **this world** renders text in the session window:

| Control | What it does |
|---------|----------------|
| **Fore / Back / Link color** | Default text, background, and hyperlink colors for the output pane. |
| **Body font** and **size** | Proportional font for normal output text. |
| **Interpret ANSI codes** | When on, ANSI color and style sequences from the server are shown using the global palette from **Settings → Colors**. When off, raw escape codes may appear as gibberish. |
| **Interpret HTML tags** | When on, simple HTML in output is rendered. Enables **Code font** and size for `<code>` regions. |
| **Code font** and **size** | Monospace font for HTML code blocks (only when HTML interpretation is on). |

The preview pane at the top shows sample styled text as you change options; long lines wrap within the pane (no horizontal scrollbar). Per-world fonts respect **Settings → Input & Display → Mono fonts only** when choosing monospace faces.

ANSI **palette** colors are app-wide—see [ANSI colors](#ansi-colors). This tab sets base fore/back/link and fonts for the world.

### Input tab

Controls how Savitar handles what you type and how commands are sent to the server.

#### Input echoing

Choose whether typed input is copied into the **output** pane:

| Option | Behavior |
|--------|----------|
| **No echo** | Input is sent to the server only; nothing is shown locally |
| **Echo carriage return only** | Only a line break appears in output when you press Return |
| **Echo all input** | The full command line is shown in output before it is sent |

#### Sticky commands

When **Sticky commands** is checked, pressing Return after a command **leaves the text selected** in the input line instead of clearing it. Type over the selection or press ↑/↓ to recall history as usual. Useful when you send the same command repeatedly with small edits.

#### Markers

Markers are short strings Savitar recognizes in commands, triggers, and macros:

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

#### Input pane size

| Control | Description |
|---------|-------------|
| **Input rows** | Height of the command-entry pane in text rows (default **2**). Changing this resizes the split between output and input when you click **OK**. |

See also [Session window](#session-window) for resizing by dragging the window or split divider.

### Output tab

| Control | Description |
|---------|-------------|
| **Columns** | Width of the output and input panes in monospace character columns (default **80**). Changing this resizes the session window when you click **OK**. |
| **Output rows** | Height of the output pane in text rows (default **24**). |
| **Logging Enabled** | When on, Savitar writes session output to a log file in the background |
| **Append / Overwrite** | Whether each session adds to the file or replaces it |
| **Log file path** | Where the log is stored; use **Set now** to pick a location |

Session logging is separate from **text document** windows and from **File → Print…**. See [Text documents](#text-documents) under the File menu.

### Closing tab

When you close a **connected** session window (or quit Savitar while worlds are connected), Savitar can send a **logoff command** to the game before disconnecting—so the server records a clean quit instead of a dropped connection.

| Control | What it does |
|---------|----------------|
| **Logoff command** | Command sent to the world on close (for example `quit`, `@quit`, or `QUIT`). Leave blank to disconnect without sending anything. |
| **Close window automatically** | When on, the window closes right after disconnect. When off (default), Savitar shows the **offline** panel first—you close again to dismiss the document. |

Imported Savitar 1 worlds keep their `LOGOFFCMD` and `autoClose` flag from world XML (`FLAGS="…+autoClose"`). Changes apply when you click **OK** and take effect the next time you close a connected session.

---

## Privacy & usage statistics

Official Savitar builds from Heynow Software send **anonymous usage statistics** to help measure active installations and version adoption. We use [TelemetryDeck](https://telemetrydeck.com/), a privacy-first analytics service: signals include app version, build number, and macOS version only — **no account names, world names, session text, or other personal data**.

Each installation uses a hashed identifier; TelemetryDeck does not receive your name, email, or IP address in a form that identifies you. You can read more in [TelemetryDeck's privacy policy](https://telemetrydeck.com/privacy/).

Local development builds, unit tests, and builds you compile from source **do not** send analytics unless you configure a TelemetryDeck App ID yourself.

The same policy is published on the web at [heynow.com/savitar/privacy](https://www.heynow.com/savitar/privacy.html) for App Store review, search, and users who prefer a browser.

---

## Getting help

1. **Savitar Help** — **Help → Savitar Help** (⌘?) opens this guide inside the app (works offline).
2. **About Privacy** — **Help → About Privacy…** opens the [Privacy & usage statistics](#privacy) chapter (what we collect and what we do not).
3. **Privacy on the web** — [heynow.com/savitar/privacy](https://www.heynow.com/savitar/privacy.html) mirrors the in-app disclosure.
4. **Release notes** — **Help → Release Notes…** lists recent changes on the web.
5. **Send Feedback** — **Help → Send Feedback…** opens your email app with a pre-filled message to the Savitar team. Include what you were doing, what went wrong, and whether it is a bug or a feature idea. You do not need a GitHub account. We read every message; response time varies during the alpha.
6. **Savitar website** — [heynow.com/savitar](https://www.heynow.com/savitar/) shows alpha news on the landing page when we are in an active test period.
7. **Web guide** — the latest draft of this guide is also in the [Savitar 2 repository](https://github.com/jkoutavas/Savitar2/blob/master/docs/USER_GUIDE.md).

Before reporting a problem, check the relevant chapter here (triggers, speech, world settings). **Help → Send Feedback…** already includes your Savitar version and macOS version in the message body.

---

## More chapters (planned)

Most beta-critical material is now in this guide. Remaining Story 9 work:

| Topic | Status |
|-------|--------|
| Getting started, install, worlds, session, commands, triggers, glossary | ✅ This guide (July 2026) |
| **Aliases** (Story 10) | Blocked on implementation |
| **Macro Clicker** (Story 11) | Shipped |
| MCP | Deferred |
| **`xch_cmd` links** | Shipped — see [HTML in output](#html-in-output) |
| **`##upload`** | Shipped — see [Local commands](#local-commands) |
| **`##capture`** | Shipped — see [Session logging](#session-logging) and [Local commands](#local-commands) |
| **Status bars** (`##set status`) | Shipped—inverse colors; styling setting planned for 2.1 |
| **Local commands** (2.0 set) | Shipped—see [Local commands](#local-commands) |
| **Session word wrap** live toggle (Story 20) | Post–2.0 |

See [Stories.md](Stories.md) for the full v1 manual map.
