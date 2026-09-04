# echoserver

Local telnet echo server for Savitar development (port **1337**).

## Build and run

```bash
cd server/echoserver
swift build
.build/debug/echoserver
```

macOS no longer ships a `telnet` CLI. Connect with Savitar instead:

1. Run Savitar from Xcode (so Launch Services sees this build).
2. In Terminal:

```bash
open -b com.heynow.savitar2 'telnet://127.0.0.1:1337'
```

Or add a World Picker entry / World Wizard host `127.0.0.1`, port `1337`, and Connect.

For a raw TCP check without Savitar: `nc 127.0.0.1 1337` (type a line and press Return; `QUIT` to leave).

## What it sends

On connect, the preamble includes:

- ANSI color/style samples
- A plain URL (`https://www.heynow.com/savitar`)
- Basic HTML examples — `<b>`, `<i>`, `<u>`, `<code>`, `<font color="…">`, and a normal `<a href="…">`
- **Pueblo `xch_cmd` links** — `<a xch_cmd="look">`, `<a xch_cmd="who" xch_hint="…">`, etc.

Enable **Interpret HTML tags** on the world (`##set html on` or World Settings → Output) to render the HTML examples and links. **`xch_cmd` links** send the embedded command when clicked (use your local-command marker for Savitar commands, e.g. `##help`).

Commands typed or sent via links are echoed back as `Server response:` lines. Type `QUIT` to disconnect or `SHUTDOWN` to stop the server.
