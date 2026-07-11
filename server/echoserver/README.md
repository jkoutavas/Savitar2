# echoserver

Local telnet echo server for Savitar development (port **1337**).

## Build and run

```bash
cd server/echoserver
swift build
.build/debug/echoserver
```

Connect from Savitar using world URL `telnet://127.0.0.1:1337`, or from the shell: `telnet 127.0.0.1 1337`

## What it sends

On connect, the preamble includes:

- ANSI color/style samples
- A plain URL (`https://www.heynow.com/savitar`)
- Basic HTML examples — `<b>`, `<i>`, `<u>`, `<code>`, `<font color="…">`, and a normal `<a href="…">`
- **Pueblo `xch_cmd` links** — `<a xch_cmd="look">`, `<a xch_cmd="who" xch_hint="…">`, etc.

Enable **Interpret HTML tags** on the world (`##set html on` or World Settings → Output) to render the HTML examples and links. **`xch_cmd` links** send the embedded command when clicked (use your local-command marker for Savitar commands, e.g. `##help`).

Commands typed or sent via links are echoed back as `Server response:` lines. Type `QUIT` to disconnect or `SHUTDOWN` to stop the server.
