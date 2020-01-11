# README #

Last updated: January 10th, 2020

Welcome to the Savitar 2.0 git repository

## Current state of the application

[![Build status](https://build.appcenter.ms/v0.1/apps/eab29aae-547c-410b-a125-2ac600f31778/branches/master/badge)](https://appcenter.ms)

Savitar 2.0 is using [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) for its output pane, converting incoming ANSI escape sequences to HTML using a hacked version of [Aha](https://github.com/theZiz/aha). Although the first release of Savitar 2.0 is aimed at feature parity with current production Savitar, v1.6.3, future releases of Savitar 2 will start taking advantages with all the goodies of having an HTML engine for output.

Here is the current state of getting to Savitar v1.6.3 feature parity, broken into two delivery parts:

### start of alpha

```
√ Started a private github repo
√ App is 64bit only, runs on macOS 10.12 and later, including Catalina
√ App is integrated with AppCenter, handles crash reporting and basic analytics
√ Reading Sav 1.x world settings, opening sessions
√ Integerated WKWebView as the output pane
√ World settings Appearance tab is operational
√ Output triggers are working
√ Load Sav 1.x app settings (includes triggers)
√ Load Sav 1.x world triggers
_ Input pane command recall and local commands supported
_ Implement input triggers
_ Implement Triggers Window
_ Implement World settings Starting tab
_ Connect/disconnect session handling
_ Implement remaining World settings tabs
_ Menubar finalized
_ Logging
_ Add check for updates support (Sparkle?)
_ Add bug reporting support
```

### start of beta

```
_ Move github repo to public
_ Release alpha to select testers, start geting feedback
_ rewrite Aha
_ Enhanced analytics
_ ANSI Color Settings window implemented
_ Macro Clicker
_ MCP (? does anyone use this?)
_ Audio & Speech
_ File upload
_ Polish
```

### Post first release

These features take Savitar 2.0 beyond what 1.6.x provides:

```
_ SSL support
_ Dark Mode support
_ Javascript scripting?
_ ???
```

## How to setup development ##

In the `client` directory you'll find `Savitar2.xcworkspace`. 

You'll want to `brew install swiftlint` to ensure coding style correctness.

### The echoserver

There is a test echo server you'll need to have running before you can run the client. The echo server was a direct rip-off from here:
http://masteringswift.blogspot.com/2017/01/using-bluesocket-framework-to-create.html

Here are the steps to build and run it on macOS:

```bash
$ cd server/echoserver
$ swift build
$ .build/debug/echoserver
```

Don't sweat the build's compiler's warnings, those are just copy/paste results from the rip-off.

If you want to generate an xcode project for the echoserver, do this:

```bash
$ cd server/echoserver
$ swift package generate-xcodeproj
```


## Tracking lines of code

`cloc . --exclude-dir=Pods`

### January 10th

```
     162 text files.
     156 unique files.                                          
      58 files ignored.

github.com/AlDanial/cloc v 1.84  T=0.44 s (249.4 files/s, 35503.2 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                           62           2107           2110           6439
XML                             13              0             17           2067
C                                1             76             52           1008
Markdown                         5            165              0            473
Bourne Shell                    10             66            173            287
YAML                             4             11              5            158
JSON                             5              0              0            104
Perl                             1             19             30             65
Ruby                             1              1              0             18
D                                4              0              0             12
C/C++ Header                     3             10             35             11
-------------------------------------------------------------------------------
SUM:                           109           2455           2422          10642
-------------------------------------------------------------------------------
```
