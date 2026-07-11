### Added

- **Events window HIG** — close-only utility chrome, center on first open, shared `EventsWindowController` for app-wide and per-world Events windows (Story 6)
- **App-wide appearance** — **Settings → Input & Display** popup: **System**, **Light**, or **Dark** for app chrome (Story 26; v2-only pref)
- **Savitar Help** — help book CSS supports light and dark appearance (`prefers-color-scheme`)
- **Window → Show World Picker** — reopen or bring forward the World Picker from the Window menu (Story 25)

### Changed

- **Events window** — list column (440pt, all columns visible) with detail editor filling the rest (~460pt); no split divider
- **Window menu** — no longer shows **Show/Hide Tab Bar** or **Merge All Windows** (Savitar does not use tabbed windows); **File → New World Document…** (⌘N) opens the World Picker (Story 25)

### Fixed

- **Events → Macros detail pane** — form built in code with standard bordered fields (Name, Hotkey, Value); hotkey displays assigned key and updates when selection changes
- **World session help** — contextual **?** opens the [Session window](docs/USER_GUIDE.md#session-window) chapter
- **World Picker** — layer-backed colors refresh when macOS Auto light/dark changes or appearance pref changes

