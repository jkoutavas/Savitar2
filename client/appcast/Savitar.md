### Added

- **World Picker** — redesigned first-run layout: welcome header, two-line world rows (`host:port`), connection detail card, primary **Connect** button (Story 7)
- **Settings → Advanced** — **Restore Factory Defaults…** reloads bundled app settings, World Picker world list, universal triggers/macros, and ANSI colors; clears utility-window positions (Stories 23–24)
- **Mordor MUD** added to bundled default worlds (`mordormud.net:4000`)
- User guide **Advanced** chapter and contextual **?** anchor (`#settings-advanced`)

### Changed

- **Bundled world addresses** — FurToonia → `ft.furtoonia.net:9999`; The Builder's Academy → `tbamud.com:9091` (verified via MUD Connect)
- **World Picker** — position-only frame restore (`WorldPickerFrameOrigin`); **Escape** / **⌘W** dismiss; window sizes to world list
- **App Settings** — seventh toolbar pane **Advanced** (`gearshape.2`); **⌘.** dismisses Settings when key (Story 23)
- **World Settings** — tab picker appears in the sheet toolbar (Starting, Appearance, Input, Output, Closing)
- **World Settings dialog** — OK/Cancel (was Apply); Escape dismisses; modal child window with visible title (`Document — Tab`); resizes per tab; Appearance preview word-wraps; sample text copyright/URL updated
- **User guide** — World Picker, Advanced, and settings reference updated; help book rebuilt
- **Stories.md** / **HIG.md** — Story 7 (World Picker HIG) and Story 23 (App Settings HIG) marked complete; Story 24 tracks Advanced maintenance backlog

### Removed

- **Mediterranean Nights** removed from bundled default worlds (host offline)

### Fixed

- World Picker **?** opens the World Picker chapter (`#worlds-connection-world-picker`); WKWebView scrolls to the target section after load

