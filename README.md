# Savitar v2.0

Savitar 2 is the next major version of [Savitar v1.x](https://heynow.com/savitar/)

![](client/Savitar2/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

README last updated: July 5th, 2022

[![Build status](https://build.appcenter.ms/v0.1/apps/eab29aae-547c-410b-a125-2ac600f31778/branches/master/badge)](https://appcenter.ms)

Chronological [Software Design Notes](docs/Savitar2DevNotes.md) are available for viewing.

## Current state of the application

With the release of macOS 10.15, Catalina, Apple has dropped support for 32-bit applications, thus finally making the 23 year old Savitar v1.x app unrunnable on Catalina. The top goal for this first v2.0 release of Savitar is to gain 64-bit support and continue to support the application moving forward. Savitar v1.6.3's heart is its [WASTE text engine](https://en.wikipedia.org/wiki/WASTE_text_engine), which is built atop 32-bit Carbon API calls. Savitar v1.6.3 was also implemented in MetroWerks' [PowerPlant application framework](https://en.wikipedia.org/wiki/PowerPlant). So, v2.0 becomes a complete rewrite of the features of Savitar v1.6.3 with a daring twist to the story: Savitar 2.0 is using [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) for its output pane, converting incoming ANSI escape sequences to HTML using a hacked version of [Aha](https://github.com/theZiz/aha). 

Although the first release of Savitar 2.0 is aimed at feature parity with current production Savitar, v1.6.3, future releases of Savitar 2 will start taking advantages with all the goodies of having an HTML engine for output.

To expediate the migration to 64-bit, the initial release of Savitar 2.0 will import existing Savitar v1.6.3 world documents and settings, and will have basically the same user interface too. If interest in the application continues/grows, subsequent 2.x versions of the app will see a redesign of the user interface of Savitar. I have also conciously avoided moving to new (to Savitar 1's timeframe) Apple technologies such as Core Data and SwiftUI. Those technologies can arrive after the first release of v2.0, and in fact, may even signal a 3.0 effort.

Here is the current state of getting to Savitar v1.6.3 feature parity, broken into two delivery parts:

### start of alpha

```
√ Started a private github repo
√ App is 64bit only, runs on macOS 10.12 and later, including Catalina
√ App is integrated with AppCenter, handles crash reporting and basic analytics
√ Reading Sav 1.x world settings, opening sessions
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
√ Implement Continuous Speech (using new AVSpeechSynthesizer)
_ Implement the start of local commands, ##history
_ Implement sticky commands
_ Handle left-arrow, right-arrow, ctrl-a, ctrl-c, and bell input
√ Implement audio cue triggers
√ Implement reply triggers
√ Implement input triggers
_ Implement input trigger variables
_ Implement next gen startup commands (trigger based)
√ Implement Trigger Matching tab view
√ Implement Trigger Appearance tab view
√ Implement Trigger Audio Cue tab view
√ Implement Trigger Reply tab view
√ Implement Macro editor
_ Implement World settings Starting tab
√ Connect/disconnect session handling
_ Implement remaining World settings tabs
_ Implement remaining local commands
_ Implement scroll locking
_ Menubar finalized
√ Text Editing menu items finalized
_ Add check for updates support (Sparkle?)
_ Add bug reporting support
_ Release alpha to select testers, start geting feedback
_ Address key things found in alpha test
```

### start of beta

```
√ Move github repo to public
_ Start promoting the beta test
_ Find/Find Next supported
√ Logging support
_ Printing supported
_ Enhanced analytics
_ ANSI Color Settings window implemented
_ Macro Clicker
_ xch_cmd support
_ MCP (? does anyone use this?)
_ File upload
_ Divider status bar support
_ Polish, address beta test issues
```

### Post first release

These features take Savitar 2.0 beyond what 1.6.x provides:

```
_ SSL support
_ Dark Mode support
_ Text to emoji support
_ Javascript scripting?
_ ???
```

## How to setup development

In the `client` directory you'll find `Savitar2.xcworkspace`. 

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

## Formatting code

Install the formatter:

```bash
$ brew install swiftformat
```

Then issue this at the command at the root of the clone:

```bash
$ swiftformat .
```

There's already a `.swiftformat` config file that contains this:

```
--swiftversion 5 
--disable wrapMultilineStatementBraces, trailingCommas
```

## Tracking lines of code

`cloc . --exclude-dir=Pods,.build`

```
     167 text files.
     151 unique files.                                          
      71 files ignored.

github.com/AlDanial/cloc v 1.92  T=0.32 s (478.6 files/s, 53394.6 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                          115           1773           1270           8162
XML                             27              0             38           4758
Markdown                         6            263              0            490
JSON                             1              0              0             68
YAML                             1              1              0              8
C/C++ Header                     1              3              8              3
-------------------------------------------------------------------------------
SUM:                           151           2040           1316          13489
-------------------------------------------------------------------------------
```
