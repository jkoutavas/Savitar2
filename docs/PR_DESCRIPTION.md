# Handle input editing keys and terminal bell

## Summary

Implements core session input-pane behavior from the alpha checklist: left/right arrow cursor movement, Ctrl-A/C line editing, Ctrl-G bell input, and incoming BEL handling in the output pane. Editing keys are handled **before** macro expansion so hotkeys cannot steal navigation chords.

Also adds `docs/Stories.md` — a settings/preferences epic for follow-up work — and updates `README.md` accordingly.

### Input pane

| Key | Behavior |
|-----|----------|
| **← / →** (unmodified) | Move cursor within the input line |
| **Ctrl-A** | Move to beginning of line |
| **Ctrl-C** | Send `\x03` (interrupt) to the server |
| **Ctrl-G** | Send `\x07` (BEL) to the server |

Editing-key detection lives in `InputEditingKeys` so chord matching is unit-testable.

### Terminal bell (output)

Incoming BEL (`\x07`) in server output:

- Plays the system beep via `NSSound.beep()` when **Mute terminal bell** is off
- Is stripped from displayed, logged, and spoken text

This wires the existing `muteBell` preference flag to behavior (partial Story 2.4 from `docs/Stories.md`).

### Other fixes

- `suppressChangeCount` is now set only for Return and command-history Up/Down, not for every keydown (including arrows)

## Changes

| Area | Files |
|------|-------|
| Input key handling | `client/Savitar2/src/worldDocument/InputViewController.swift`, `InputEditingKeys.swift` |
| Output bell | `client/Savitar2/src/worldDocument/OutputView.swift`, `TerminalBell.swift` |
| Tests | `client/Savitar2Tests/InputEditingKeysTests.swift`, `TerminalBellTests.swift` |
| Docs | `docs/Stories.md`, `README.md` |
| Project | `client/Savitar2.xcodeproj/project.pbxproj`, `Package.resolved` |

## Test plan

- [ ] In a connected session, type text and use **← / →** to move the cursor within the line
- [ ] **Ctrl-A** moves the cursor to the beginning of the line (not Select All)
- [ ] **Ctrl-C** sends interrupt to the server (world-dependent response)
- [ ] **Ctrl-G** sends BEL to the server (most worlds ignore it; no local echo expected)
- [ ] When the server sends BEL in output, hear a system beep
- [ ] With **Audio → Mute terminal bell** (or `muteBell` in prefs XML), incoming BEL is silent
- [ ] Confirm unmodified arrow keys are not consumed by macros bound to left/right arrow
- [ ] Run `InputEditingKeysTests` and `TerminalBellTests` in Xcode

## Notes

- Outgoing Ctrl-G only affects worlds that handle BEL; incoming BEL is the common MUD-client case
- Mute-bell UI in App Preferences is still future work (`docs/Stories.md` Story 1); the flag already exists and is honored on output
