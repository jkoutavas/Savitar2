# Fastlane Release Builds

This Fastlane setup builds, signs, notarizes, and packages Savitar. It never
commits certificates, passwords, API keys, release archives, or notarized
artifacts. Dependencies are managed by Swift Package Manager, so there is no
`pod install` step.

> This file is hand-written. The Fastfile calls `skip_docs`, so fastlane will
> not overwrite it with its auto-generated lane index.

Releases can be produced two ways:

- **Locally**, on your Mac, using your login Keychain and local env vars.
- **In CI**, via the `Release` GitHub Actions workflow, which only the repo
  owner can trigger (see [CI releases](#ci-releases-owner-only)).

## One-Time Setup (local)

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

Run the unsigned local test build (matches the pull-request CI build):

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
client/fastlane/release/Savitar.zip
```

## CI Releases (owner-only)

The `.github/workflows/release.yml` workflow runs the `release` lane on a
GitHub-hosted `macos-26` runner and attaches the signed, notarized zip to the
GitHub Release.

It is locked down so that only the repository owner can produce an official
signed build:

- It triggers **only** on `v*` tag pushes and manual `workflow_dispatch` — both
  require write access to this repository. Pull requests (including from forks)
  cannot trigger it, and GitHub never exposes secrets to fork PRs.
- Signing secrets are stored in a protected **`release` environment**, so the job
  pauses for a **required reviewer** (you) before it can read them.
- An `if: github.repository == 'jkoutavas/Savitar2'` guard prevents forked copies
  of the workflow from attempting a release.

### One-time GitHub configuration

1. **Create the environment:** Settings → Environments → **New environment** →
   name it `release`.
2. **Add a protection rule:** enable **Required reviewers** and add yourself.
   (Optionally restrict deployment to protected tags.)
3. **Add these secrets to the `release` environment** (Settings → Environments →
   `release` → Environment secrets):

   | Secret | What it is |
   | --- | --- |
   | `MACOS_CERT_P12_BASE64` | Base64 of your exported *Developer ID Application* certificate **including its private key** (`.p12`) |
   | `MACOS_CERT_PASSWORD` | Password you set when exporting the `.p12` |
   | `APPLE_TEAM_ID` | e.g. `RFE485QN84` |
   | `DEVELOPER_ID_APPLICATION` | e.g. `Developer ID Application: Your Name (RFE485QN84)` |
   | `APP_STORE_CONNECT_KEY_ID` | App Store Connect API key ID |
   | `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |
   | `APP_STORE_CONNECT_KEY_P8_BASE64` | Base64 of the App Store Connect API key file (`.p8`) |

   Generate the base64 blobs with:

   ```bash
   base64 -i DeveloperID.p12 | pbcopy
   base64 -i AuthKey_ABC123DEFG.p8 | pbcopy
   ```

### Cutting a release

```bash
git tag v2.0.0
git push origin v2.0.0
```

Then approve the pending `release` deployment in the Actions tab. The workflow
signs, notarizes, staples, and uploads `Savitar.zip` to the `v2.0.0` GitHub
Release.

## Notes

- Local release lanes sign with your login Keychain; CI imports the certificate
  into a temporary, throwaway keychain that is deleted at the end of the run.
- The app target already enables the hardened runtime, which is required for
  notarization.
- `com.apple.security.get-task-allow` is intentionally **not** in
  `Savitar2.entitlements`. Xcode injects it automatically for local Debug builds
  (so debugging works), while Developer ID archives ship without it — which is
  what notarization and the hardened runtime require. Don't add it back to the
  entitlements file.
