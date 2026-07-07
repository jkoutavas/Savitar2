# Sparkle appcast

This directory holds the Sparkle update feed for Savitar.

| File | Purpose |
| --- | --- |
| `appcast.xml` | Committed feed read by the app (`SavitarUpdater`) and updated on each tagged release |
| `Savitar.md` | Release notes for the current feed item (relative `releaseNotesLink` target; commit beside `appcast.xml`) |
| `updates/` | Staging folder for `generate_appcast` (release zips are gitignored) |

**Version History:** each appcast item includes `sparkle:fullReleaseNotesLink` pointing at the repo
[`CHANGELOG.md`](https://github.com/jkoutavas/Savitar2/blob/master/CHANGELOG.md). Per-version
`Savitar.md` files are still used when prompting to install an update.

Feed URL (also set in `SavitarUpdater.swift`):

```text
https://raw.githubusercontent.com/jkoutavas/Savitar2/master/client/appcast/appcast.xml
```

## One-time EdDSA key setup (owner)

Run once on your Mac after resolving Swift packages:

```bash
cd client
xcodebuild -resolvePackageDependencies \
  -project Savitar2.xcodeproj -scheme Savitar2 \
  -derivedDataPath build/sparkle-tools

SPARKLE_BIN=build/sparkle-tools/SourcePackages/artifacts/sparkle/Sparkle/bin

# Creates a key pair in your login keychain; prints the public key for Info.plist.
"$SPARKLE_BIN/generate_keys"

# Export the private seed for CI (store in GitHub `release` environment secrets).
mkdir -p ~/.private
"$SPARKLE_BIN/generate_keys" -x ~/.private/savitar-sparkle-ed25519.key
```

1. Paste the printed public key into **Xcode → Savitar2 target → Build Settings →
   `SPARKLE_PUBLIC_ED_KEY`** (maps to `SUPublicEDKey` in `Info.plist`).
2. Add the **entire contents** of `~/.private/savitar-sparkle-ed25519.key` to the
   `release` environment secret **`SPARKLE_EDDSA_PRIVATE_KEY`**.

## Bootstrap appcast for an existing release

If a GitHub Release already exists (e.g. `v2.0.16`) before Sparkle shipped:

```bash
cd client
export SPARKLE_EDDSA_PRIVATE_KEY="$(cat ~/.private/savitar-sparkle-ed25519.key)"
VERSION=2.0.16 TAG=v2.0.16

mkdir -p appcast/updates
cp fastlane/release/Savitar.zip "appcast/updates/Savitar-${VERSION}.zip"
# Release notes beside the archive (Markdown is supported by Sparkle 2.9+).
awk -v ver="$VERSION" '
  $0 ~ "^## \\[" ver "\\]" { capture = 1; next }
  capture && /^## \[/ { exit }
  capture { print }
' ../CHANGELOG.md | awk "NF { seen = 1 } seen" > "appcast/updates/Savitar-${VERSION}.md"

"$SPARKLE_BIN/generate_appcast" \
  --download-url-prefix "https://github.com/jkoutavas/Savitar2/releases/download/${TAG}/" \
  appcast/updates

mv appcast/updates/appcast.xml appcast/appcast.xml
cp appcast/updates/*.md appcast/
git add appcast/appcast.xml appcast/*.md
git commit -m "Bootstrap Sparkle appcast for ${TAG}"
git push
```

On every future tagged release, CI opens a pull request with the updated appcast (direct
pushes to `master` are blocked by branch protection). Merge that PR to publish the feed.
