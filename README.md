# README #

Welcome to the Savitar 2.0 git repository

## How do I get set up? ##

Things are pretty basic right now. A server connection is hard-wired into the client.

In the clients directory you'll find the xcode workspace for building the macOS target of the client app.

There is a test echo server you'll need to have running before you can run the client. The echo server was a direct rip-off from here:
http://masteringswift.blogspot.com/2017/01/using-bluesocket-framework-to-create.html

Here are the steps to build and run it on macOS:

```bash
$ cd server/echoserver
$ swift build
$ .build/debug/echoserver
```

Don't sweat the build's compiler's warnings, those are just copy/paste results from the rip-off.

