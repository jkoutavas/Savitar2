### Added

- **Keepalive Minutes** — World Settings → Starting now sends Savitar 1–style idle keepalive: after N minutes with no outbound traffic, a quiet null byte is written on the TCP connection (`0` = off); timer resets on sends; a failed keepalive closes the session (#105)
- **Retry Seconds** — World Settings → Starting auto-reconnects after an unexpected disconnect or failed connect when set above `0` (Savitar 1 parity; `0` = off); Stop cancels a pending retry

### Fixed

- **Input caret / send window focus** — restoring the session window after backgrounding, using Services on output text, or dismissing Find no longer leaves typing stuck with no caret in the send window; printable keys reclaim the input line while Cmd/Ctrl shortcuts (e.g. Copy from output) still work (#105)

