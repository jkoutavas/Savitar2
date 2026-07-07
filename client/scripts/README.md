# Client scripts

## `build_help_book.py`

Regenerates the in-app **Savitar.help** bundle from `docs/USER_GUIDE.md` (Story 16).

```bash
# From repository root
python3 client/scripts/build_help_book.py
```

Run this after editing the user guide, then rebuild Savitar in Xcode. The script:

1. Converts `USER_GUIDE.md` to `index.html` + CSS under `client/Savitar2/resources/Savitar.help/`
2. Runs macOS `hiutil` to build `Savitar.helpindex` for Apple Help Viewer search

If `hiutil` is unavailable, HTML is still generated; the app falls back to an in-window guide (`HelpGuideWindowController`).

**Stable section anchors** (for Story 17 contextual help) are defined in the script’s `ANCHOR_BY_TITLE` map and mirrored in `SavitarHelp.Anchor`.
