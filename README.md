# Savitar v2.0

_README last updated July 24th, 2026_

Savitar 2 is the next major version of [Savitar v1.x](https://github.com/jkoutavas/savitar140). For the story of how a 32-bit Carbon client became a modern rewrite—and where that journey stands today—see **[From Savitar 1 to Savitar 2](docs/JOURNEY.md)**.

![](client/Savitar2/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

[![Test Build](https://github.com/jkoutavas/Savitar2/actions/workflows/test-build.yml/badge.svg?branch=master)](https://github.com/jkoutavas/Savitar2/actions/workflows/test-build.yml)
[![Release](https://github.com/jkoutavas/Savitar2/actions/workflows/release.yml/badge.svg)](https://github.com/jkoutavas/Savitar2/actions/workflows/release.yml)

**Quick links:** [Releases](https://github.com/jkoutavas/Savitar2/releases) · [Changelog](CHANGELOG.md) · [User Guide](docs/USER_GUIDE.md) · [Release process](client/fastlane/README.md) · [Sparkle appcast](client/appcast/README.md)

## Documentation

| Document                                               | Audience   | Contents                                                                                                                                      |
| ------------------------------------------------------ | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| [CHANGELOG.md](CHANGELOG.md)                           | Everyone   | Version history and release notes ([Keep a Changelog](https://keepachangelog.com/); also Sparkle **Version History** in the app)              |
| [docs/JOURNEY.md](docs/JOURNEY.md)                     | Everyone   | Reading the dev notes against today: the Savitar 1 → 2 arc, in the spirit of the original assessment                                          |
| [docs/USER_GUIDE.md](docs/USER_GUIDE.md)               | Users      | How to use the app ([Story 9](docs/Stories.md#story-9--user-guide-full-app-documentation); bundled in-app as **Savitar Help**, Stories 16–17) |
| [docs/Stories.md](docs/Stories.md)                     | Developers | Settings, prefs, and HIG backlog as user stories                                                                                              |
| [docs/HIG.md](docs/HIG.md)                             | Developers | macOS UI requirements — windows, menus, controls; scope vs Stories and USER_GUIDE                                                             |
| [docs/Savitar2DevNotes.md](docs/Savitar2DevNotes.md)   | Developers | Chronological software design notes (2019–2020); see [JOURNEY.md](docs/JOURNEY.md) for the narrative arc                                      |
| [docs/OutputPerformance.md](docs/OutputPerformance.md) | Developers | Session output scrollback, beta perf plan, diagnostics overlay ([Story 27](docs/Stories.md#story-27--output-scrollback--performance))         |

## Current state of the application

With the release of macOS 10.15, Catalina, Apple dropped support for 32-bit applications, finally making the 23-year-old Savitar v1.x app unrunnable on Catalina. The top goal for this first v2.0 release is 64-bit support and continued maintenance. Savitar v1.6.3's heart is its [WASTE text engine](https://en.wikipedia.org/wiki/WASTE_text_engine), built atop 32-bit Carbon API calls. v1.6.3 was also implemented in MetroWerks' [PowerPlant application framework](https://en.wikipedia.org/wiki/PowerPlant). v2.0 is a complete rewrite toward v1.6.3 feature parity, with one major architectural change: the output pane uses [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview), converting incoming ANSI escape sequences to HTML with a hacked version of [Aha](https://github.com/theZiz/aha).

Although the first release targets feature parity with production Savitar v1.6.3, future 2.x releases can take advantage of an HTML output engine. To expedite the 64-bit migration, v2.0 imports existing v1.6.3 world documents and settings and keeps basically the same user interface. I have consciously avoided newer (for Savitar 1's era) Apple technologies such as Core Data and SwiftUI until after the first v2.0 ship; those may signal a 3.0 effort.

### start of alpha

#### Progress toward v1.6.3 feature parity

```
√ Started a private github repo
√ App is 64bit only, runs on macOS 10.12 and later, including Catalina
√ Reading Sav 1.x world settings, opening sessions
√ Integrated WKWebView as the output pane
√ Rewrite Aha (ANSI to HTML parser)
√ World settings Appearance tab is operational
√ Output triggers are working
√ Input macro hotkeys are supported
√ Load Sav 1.x app settings (includes triggers)
√ Load Sav 1.x world triggers
√ Transition over to using ReSwift (break-out extensions of classes/structs as needed)
√ Implement input pane command recall
√ New world onboarding
√ Continuous speech (AVSpeechSynthesizer on macOS 10.15+; NSSpeechSynthesizer fallback)
√ Speech settings in app Settings → Speech pane (voice, rate, enable; v1 prefs import)
√ Speech menus — Edit → Speech → Speak Selected Text (input + output); Audio → Flush Speech Buffer (⌘L), Speech Settings…
√ Implement the start of local commands, ##history
√ Implement sticky commands
√ Handle left-arrow, right-arrow, ctrl-a/e/u/w/c, and bell input
√ Implement audio cue triggers
√ Implement reply triggers
√ Implement input triggers
√ Implement input trigger variables
√ Implement Trigger Matching tab view
√ Implement Trigger Appearance tab view
√ Implement Trigger Audio Cue tab view
√ Implement Trigger Reply tab view
√ Implement Macro editor
√ Implement World settings Starting tab
√ Keepalive Minutes — idle null-byte probe on outbound silence (v1 parity; World Settings → Starting)
√ Retry Seconds — auto-reconnect after unexpected disconnect / failed connect (v1 parity; `0` = off)
√ Connect/disconnect session handling
√ World settings Input tab — input echo, sticky commands, command marker, CR/LF postfix, variable (%%) and wildcard ($$) markers, input rows
√ World settings Output tab (partial) — session logging (path, append/overwrite); pane columns and output rows
~~ World settings Output tab — buffer size, flush period~~ (won't do — [OutputPerformance.md](docs/OutputPerformance.md))
√ World settings Closing tab — logoff/disconnect command on close; auto-close
√ World settings sheet — OK/Cancel, settings window title (world + tab), per-tab resize, Appearance preview wrap
√ Implement remaining local commands (##history, ##dump, flags, triggers, windows, ##wait, ##link, ##help, … — [USER_GUIDE](docs/USER_GUIDE.md#local-commands))
√ Local command ##upload
√ Local command ##capture
√ Local command ##open text window
√ Local command ##send window
√ Local command ##add world
√ Local command ##dump connection
√ Local command ##dump variables
√ Local command ##play
√ Menubar finalized (world + text documents, Audio, Edit → Speech, Find, Print; see docs/HIG.md and docs/USER_GUIDE.md)
√ App Settings window — HIG toolbar panes: Startup, Input & Display, Audio, Updates, Speech, **Advanced** (Stories 1, 23)
√ **Restore Factory Defaults** — Settings → Advanced reloads bundled prefs and World Picker world list (Story 24.1)
√ World Picker HIG — welcome layout, keyboard dismiss, position-only restore (Story 7)
√ Wire keypad, mono fonts, mute-bell, and default word-wrap preference flags (Story 2; see docs/Stories.md)
√ Find/Find Next supported (input + output panes)
√ Printing supported (session output)
√ ANSI Color Settings pane in app Settings (Story 5)
√ Macro Clicker (Story 11)
√ xch_cmd support (Pueblo clickable command links in HTML output)
√ Implement scroll locking
√ Session status bars — ##set status output|input, ##close stats (inverse session colors)
√ Core Edit menu (undo, cut/copy/paste, clear output, find, print)
√ Contextual edit menus for session input and output panes
√ Sparkle auto-updates (Story 12)
√ Add bug reporting support (Story 15 — Help → Send Feedback…)
√ In-app Savitar Help — bundled user guide (Story 16)
√ Contextual ? help on major windows (Story 17)
√ Help → About Privacy… (Story 18)
_ ANSI intense Appearance — auto / bold / color + intense color swatch (`INTENSETYPE` / `INTENSECOLOR` import today; not wired to UI or rendering)
_ Macro pop-ups — type-ahead variable/macro completion while typing in the input pane (v1 `CTVVarPopup`)
_ Drag selected output text into Events to create a new trigger (v1 text → Events DnD; v2 Events reorder-only)
_ `xch_cmd` send mode — v1 “send immediately” vs put-in-input (`DirectXCMDs`); v2 always submits on click
_ Capture / log file editor binding — open capture/log files in a chosen app (Story 24.5)
_ `telnet://` / Web Interaction helper — open or hand off world URLs from outside the app
√ Release alpha to select testers, start getting feedback
√ Move github repo to public
```

Skipped on purpose: v1’s “italics instead of blinking” — Savitar 2 already maps ANSI blink to a CSS animation in the HTML output pane.

#### Savitar 1 local commands not planned for 2.x

From the [Savitar 1.4 manual](http://heynow.com/savitar/manual140/_mancontent6.html) — v1 stubs, disabled, or out of scope:

```
~~ ##tell application     (AppleScript — not planned)
~~ ##delete trigger|macro (v1 always returned “bad command”)
~~ ##connect / ##disconnect (disabled or broken in v1)
~~ ##clear line / ##goto  (#if 0 in v1 — XY addressing)
~~ ##show task / ##task / ##kill / ##profile / ##timer  (dev/profiling builds only)
~~ ##test / ##xy
~~ Python ##ent / ##run / backtick lines  (optional v1 build)
```

#### New 2.0 features

```
√ App-wide appearance — System / Light / Dark on Settings → Input & Display (Story 26; v2-only pref, no v1 import)
```

### Start of beta

```
√ Anonymous usage analytics via TelemetryDeck (Story 14; official release builds only)
_ Crash reporting (Sentry — separate from TelemetryDeck analytics)
_ Output scrollback optimizations + diagnostics overlay (Story 27; [OutputPerformance.md](docs/OutputPerformance.md) — honor `OUTPUTMAX`/`OUTPUTMIN`, coalesce appends, session metrics strip)
_ Start promoting the beta test
_ User guide — remaining chapters (Story 9; in-app delivery ✅ Stories 16–17; speech, menus, settings panes documented)
_ MCP (? does anyone use this?)
_ Polish, address beta test issues
```

### Post first release

These features take Savitar 2.1 beyond what 1.6.x provides:

```
- macOS 11 and beyond capabilities
_ Implement next gen startup commands (trigger based)
_ Alias support (Story 10)
_ New `##dump` aliases local command (Story 10)
_ New `##say` local command for voicing text
_ Status bar styling — per-world setting (match session / inverse / custom colors)
_ Echo back color — World Settings → Appearance swatch for `ECHOBGCOLOR` (Story 28; v1 stored the color but never shipped the control)
_ Session word wrap UX — live per-session toggle, per-world default (Story 20)
_ SSL support
_ Text to emoji support
_ Javascript scripting?
_ ??? requested new features ???
```

## How to setup development

In the `client` directory you'll find `Savitar2.xcodeproj`. Open it directly in Xcode; dependencies are managed by Swift Package Manager and resolve automatically. (Savitar no longer uses CocoaPods, so there is no `.xcworkspace` or `Podfile`.)

You'll want to `brew install swiftlint` to ensure coding style correctness.

### The echoserver

There is an echo server you can use to test with. The echo server is derived from [Using the BlueSocket framework to create an echo server](http://masteringswift.blogspot.com/2017/01/using-bluesocket-framework-to-create.html)

Here are the steps to build and run it on macOS:

```bash
$ cd server/echoserver
$ swift build
$ .build/debug/echoserver
```

If you want to generate an xcode project for the echoserver, do this:

```bash
$ cd server/echoserver
$ swift package generate-xcodeproj
```

## Releases

Official Savitar builds are Developer ID–signed and notarized by the maintainer, then attached to the project's [GitHub Releases](https://github.com/jkoutavas/Savitar2/releases). Savitar is open source, so anyone can build the app for their own use — but only the maintainer can publish a signed, notarized binary: the signing secrets live in a protected GitHub Actions environment gated behind owner approval, and the release workflow ([`.github/workflows/release.yml`](.github/workflows/release.yml)) runs only on version tags.

To produce an unsigned local build (the same one CI runs on every pull request):

```bash
$ cd client
$ bundle exec fastlane test_build
```

See [`client/fastlane/README.md`](client/fastlane/README.md) for the full release process — local and CI lanes, the required secrets, and how to cut a release.

## Formatting code

Install the formatter:

```bash
$ brew install swiftformat
```

Then issue this command at the root of the clone:

```bash
$ swiftformat .
```

There's already a `.swiftformat` config file that contains this:

```
--swiftversion 5
--disable wrapMultilineStatementBraces, trailingCommas
```
