### Added

- **Default word wrap for new sessions** — Settings → Input & Display applies word wrap to input and output panes when a world session opens (v1 `TVPrefFlag_t_DefaultWordWrap` parity)
- **Pane dimensions (rows/columns)** — World Settings → Output (columns, output rows) and Input (input rows); grow-box and split-divider resize with yellow size overlay; v1 `RESOLUTION` parity
- **Help → Savitar Help** (⌘?) opens the bundled user guide offline in a Savitar window
- **Help → Savitar Guide on the Web…** opens the latest guide draft on GitHub
- **Help → About Privacy…** opens the Privacy & usage statistics chapter in Savitar Help
- Contextual **?** help on major windows — World Picker, world session window, Events, Settings (per pane), and World Settings (per tab)
- User Guide chapters for ANSI colors, Input & Display, Audio, Updates, and World Settings (Starting and Appearance tabs)

### Changed

- User Guide expanded with contextual-help callout, Help menu reference, Getting help section updates, and Input & Display word-wrap documentation
- **Stories.md** and **HIG.md** refreshed to reflect shipped help, analytics, and settings work (July 2026 doc pass)

### Fixed

- **`RESOLUTION` XML attribute order** — parse and serialize as `columns×outputRows×inputRows` to match Savitar 1 (`CTVWorld.cp`)
- **Harper's Tale startup world** — connect to `moo.harpers-tale.com:7007` (was `harpers-tale.com`, which does not accept MOO connections)
- Pasting into the input pane no longer retains font or color styling from the clipboard source
- Unit tests no longer overwrite the live `Savitar2 Prefs` file when preference actions are exercised
- World Settings **Output** tab labels no longer truncate (“Logging Enabled”, logging mode radio buttons)

