# Local Fastlane Release Builds

This Fastlane setup is intentionally local-first. It does not require GitHub
Actions secrets and does not commit certificates, passwords, API keys, release
archives, or notarized artifacts.

## One-Time Setup

Install Bundler if needed:

```bash
gem install bundler
```

Install the local Ruby tools:

```bash
cd client
bundle install
```

Install your Developer ID Application certificate in your local macOS Keychain.
The certificate must include its private key.

## Environment Variables

Set these locally before running a release lane:

```bash
export APPLE_TEAM_ID="RFE485QN84"
export DEVELOPER_ID_APPLICATION="Developer ID Application: Your Name (RFE485QN84)"
export APP_STORE_CONNECT_KEY_ID="ABC123DEFG"
export APP_STORE_CONNECT_ISSUER_ID="00000000-0000-0000-0000-000000000000"
export APP_STORE_CONNECT_KEY_PATH="$HOME/.private/AuthKey_ABC123DEFG.p8"
```

You can put those in a local shell profile, a password manager shell snippet, or
an untracked `.env` file that you source manually. Do not commit real values.

## Lanes

Run the unsigned local test build:

```bash
cd client
bundle exec fastlane test_build
```

Create a signed Developer ID archive and zip:

```bash
cd client
bundle exec fastlane release_archive
```

Submit the zip to Apple notarization and staple the accepted ticket:

```bash
cd client
bundle exec fastlane notarize
```

Run the full local release flow:

```bash
cd client
bundle exec fastlane release
```

The release zip is written to:

```text
client/fastlane/release/Savitar2.zip
```

## Notes

- The release lanes assume signing happens on your Mac using your local
  Keychain.
- `pod install` is run automatically because the CocoaPods support files are
  ignored by git but required by the Xcode workspace.
- The app target already enables hardened runtime, which is required for
  notarization.
- Before shipping a notarized release, verify the release entitlements. In
  particular, `com.apple.security.get-task-allow` should normally be disabled
  for distribution builds.
