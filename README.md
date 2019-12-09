# README #

Last updated: December 8th, 2019

Welcome to the Savitar 2.0 git repository

[![Build status](https://build.appcenter.ms/v0.1/apps/eab29aae-547c-410b-a125-2ac600f31778/branches/master/badge)](https://appcenter.ms)

## How do I get set up? ##

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
