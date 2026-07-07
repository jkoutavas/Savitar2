# Savitar v2.0

_README last updated July 6th, 2026_

Savitar 2 is the next major version of [Savitar v1.x](https://heynow.com/savitar/). For the story of how a 32-bit Carbon client became a modern rewrite—and where that journey stands today—see **[From Savitar 1 to Savitar 2](docs/JOURNEY.md)**.

![](client/Savitar2/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

[![Test Build](https://github.com/jkoutavas/Savitar2/actions/workflows/test-build.yml/badge.svg?branch=master)](https://github.com/jkoutavas/Savitar2/actions/workflows/test-build.yml)
[![Release](https://github.com/jkoutavas/Savitar2/actions/workflows/release.yml/badge.svg)](https://github.com/jkoutavas/Savitar2/actions/workflows/release.yml)

**Quick links:** [Releases](https://github.com/jkoutavas/Savitar2/releases) · [Changelog](CHANGELOG.md) · [User Guide](docs/USER_GUIDE.md) · [Release process](client/fastlane/README.md) · [Sparkle appcast](client/appcast/README.md)

## Documentation

| Document                                             | Audience   | Contents                                                                                                                                                       |
| ---------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [CHANGELOG.md](CHANGELOG.md)                         | Everyone   | Version history and release notes ([Keep a Changelog](https://keepachangelog.com/); also Sparkle **Version History** in the app)                               |
| [docs/JOURNEY.md](docs/JOURNEY.md)                   | Everyone   | Reading the dev notes against today: the Savitar 1 → 2 arc, in the spirit of the original assessment                                                           |
| [docs/USER_GUIDE.md](docs/USER_GUIDE.md)             | Users      | How to use the app ([Story 9](docs/Stories.md#story-9--user-guide-full-app-documentation) tracks the full guide; speech, menus, events, and macros documented) |
| [docs/Stories.md](docs/Stories.md)                   | Developers | Settings, prefs, and HIG backlog as user stories                                                                                                               |
| [docs/HIG.md](docs/HIG.md)                           | Developers | macOS UI requirements (Settings window, Edit → Speech, Audio menu, …)                                                                                          |
| [docs/Savitar2DevNotes.md](docs/Savitar2DevNotes.md) | Developers | Chronological software design notes (2019–2020); see [JOURNEY.md](docs/JOURNEY.md) for the narrative arc                                                       |

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
√ Handle left-arrow, right-arrow, ctrl-a, ctrl-c, and bell input
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
√ Connect/disconnect session handling
_ Implement remaining World settings tabs
_ Implement remaining local commands
√ Implement scroll locking
√ Menubar finalized (world + text documents, Audio, Edit → Speech, Find, Print; see docs/HIG.md and docs/USER_GUIDE.md)
√ App Settings window — HIG toolbar panes: Startup, Input & Display, Audio, Updates, Speech (Story 1)
√ Wire keypad, mono fonts, and mute-bell preference flags (Story 2; see docs/Stories.md)
_ Wire default word wrap for new sessions (Story 2.3)
√ Find/Find Next supported (input + output panes)
√ Printing supported (session output)
√ ANSI Color Settings pane in app Settings (Story 5)
_ Macro Clicker
_ xch_cmd support
_ MCP (? does anyone use this?)
_ File upload
_ Divider status bar support
√ Core Edit menu (undo, cut/copy/paste, clear output, find, print)
√ Sparkle auto-updates (Story 12)
_ Add bug reporting support
_ Release alpha to select testers, start getting feedback
_ Address key things found in alpha test
```

#### New 2.0 features

```
_ Implement next gen startup commands (trigger based)
_ Alias support (Story 10)
```

### start of beta

```
√ Move github repo to public
√ Anonymous usage analytics via TelemetryDeck (Story 14; official release builds only)
_ Crash reporting (Sentry — separate from TelemetryDeck analytics)
_ Start promoting the beta test
_ User guide — remaining chapters (Story 9; speech and menus documented)
_ Polish, address beta test issues
```

### Post first release

These features take Savitar 2.1 beyond what 1.6.x provides:

```
- macOS 11 and beyond capabilities
_ SSL support
_ Dark Mode support
_ Text to emoji support
_ Javascript scripting?
_ ???
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

## Tracking lines of code

Re-run from the repo root (approximate; excludes `.build`, `build`):

```bash
cloc . --exclude-dir=.build,build --not-match-f='PR_DESCRIPTION\.md'
```

```
     178 text files.
     163 unique files.
      51 files ignored.

github.com/AlDanial/cloc v 2.04  T=0.09 s (1725.4 files/s, 223634.8 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment    code
-------------------------------------------------------------------------------
Swift                          127           2235           1360   10646
XML                             14             18             36    3954
Markdown                        15            749              0    1710
YAML                             4             34             20     272
JSON                             1              0              0      68
Text                             1              0              0      11
C/C++ Header                     1              3              8       3
-------------------------------------------------------------------------------
SUM:                           163           3039           1424   16664
-------------------------------------------------------------------------------
```
