# README #

Last updated: December 10th, 2019

Welcome to the Savitar 2.0 git repository

## Current state of the application

[![Build status](https://build.appcenter.ms/v0.1/apps/eab29aae-547c-410b-a125-2ac600f31778/branches/master/badge)](https://appcenter.ms)

Savitar 2.0 is using [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) for its output pane, converting incoming ANSI escape sequences to HTML using a hacked version of [Aha](https://github.com/theZiz/aha). Although the first release of Savitar 2.0 is aimed at feature parity with current production Savitar, v1.6.3, future releases of Savitar 2 will start taking advantages with all the goodies of having an HTML engine for output.

Here is the current state of getting to Savitar v1.6.3 feature parity, broken into two delivery parts:

### start of alpha

```
√ Started a private github repo
√ App is 64bit only, runs on Catalina
√ App is integrated with AppCenter, handles crash reporting and basic analytics
√ Reading Sav 1.x world settings, opening sessions
√ Integerated WKWebView as the output pane
√ World settings Appearance tab is operational
√ Output triggers are working
_ Load Sav 1.x app settings (includes triggers)
_ Load Sav 1.x world triggers
_ Input pane command recall and local commands supported
_ Triggers Window implemented
_ Implement World settings Starting tab
_ Connect/disconnect session handling
_ Implement remaining World settings tabs
_ Logging
_ Add check for updates support (Sparkle?)
_ Add bug reporting support
_ Enhanced analytics
```

### start of beta

```
_ Move github repo to public
_ Release alpha to select testers, start geting feedback
_ rewrite Aha
_ ANSI Color Settings window implemented
_ input triggers (? does anyone use these?)
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
_ Javascript ?
_ ???
```

## How to setup development ##

In the `client` directory you'll find `Savitar200.xcodeproj`. You'll want to `brew install swiftlint` to ensure coding style correctness.

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

