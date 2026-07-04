fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac test_build

```sh
[bundle exec] fastlane mac test_build
```

Build the app locally without signing, matching the pull request test build.

### mac release_archive

```sh
[bundle exec] fastlane mac release_archive
```

Create a Developer ID signed release archive and zip it for notarization.

### mac notarize

```sh
[bundle exec] fastlane mac notarize
```

Submit the release zip to Apple notarization and staple the accepted ticket.

### mac release

```sh
[bundle exec] fastlane mac release
```

Build, notarize, staple, and package a local release zip.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
