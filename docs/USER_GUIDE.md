# Savitar 2 User Guide

_Last updated July 2, 2026._

This guide explains how to use Savitar 2. It is being written incrementally; see [Stories.md](Stories.md) **Story 9** for the plan to complete the full guide.

Savitar 2 is intended to behave like Savitar 1.x for day-to-day use. Where behavior matches v1, this guide describes that parity explicitly.

---

## Speech

Savitar can speak text in three ways:

1. **Continuous speech** — automatically reads incoming **world output** (text the server sends to your session).
2. **Event speech** — trigger-based speech configured in the **Events** window (per trigger voice and phrase).
3. **Ad-hoc speech** — speak a **selection** in the input or output pane via **Edit → Speech → Speak Selected Text**.

All speech uses the English voices installed on your Mac. On macOS 10.15 and later, Savitar uses the modern system speech engine (`AVSpeechSynthesizer`). On earlier macOS versions, it uses the legacy `NSSpeechSynthesizer` engine instead.

### Continuous speech

Continuous speech is the feature most users mean when they turn speech on for a MUD or telnet session.

**What it does**

- When enabled, each chunk of text that arrives in the **output** pane is spoken aloud.
- ANSI color and style codes are stripped before speaking; you hear plain text.
- Continuous speech uses the **voice** and **rate** from app Speech settings (see below). These are **global** preferences—the same defaults Savitar 1 used—not per-world settings.
- Text you type in the **input** line is **not** spoken unless the world echoes it back as output.

**How to turn it on**

1. Open **Settings…** (⌘,) or **Audio → Speech Settings…**
2. Select the **Speech** toolbar tab
3. Check **Continuous speech enabled**
4. Choose a **Voice** and adjust **Rate** if desired
5. Click the speaker icon next to the voice menu to hear a sample phrase

Settings save immediately when you change them.

**Requirements**

- macOS 10.15 or later for continuous speech (the Speech pane shows a footnote on older systems).
- **Mute Speaking Cues** must be **off** in the **Audio** menu or **Settings → Audio** pane. When muted, both continuous speech and trigger speech are suppressed.

### Event (trigger) speech

Triggers in the **Events** window can play audio cues when matched:

| Cue type | Behavior |
|----------|----------|
| **Sound** | Plays a system or custom sound file |
| **Speak event** | Speaks the text that matched the trigger |
| **Say text** | Speaks a fixed phrase you configure |

Each trigger can use its own voice. The speech **rate** slider in Speech settings still applies to trigger speech, matching Savitar 1.

Trigger speech respects the same mute flags as continuous speech:

- **Mute Sound Cues** — suppresses trigger sounds only
- **Mute Speaking Cues** — suppresses trigger speech and continuous speech

### Edit → Speech

| Menu item | What it does |
|-----------|--------------|
| **Speak Selected Text** | Speak the selected text in the **input** or **output** pane (enabled when the active pane has a selection, or when the output pane is focused) |

Select text in either pane, then choose **Edit → Speech → Speak Selected Text**. This matches Savitar 1’s **Edit → Speech → Start Speaking**, which worked on selections in both WASTE text panes. Savitar 2 uses the same menu location (HIG) with a clearer label and Savitar’s voice engine.

### Audio menu

| Menu item | What it does |
|-----------|--------------|
| **Mute Sound Cues** | Toggle trigger sound effects on/off |
| **Mute Speaking Cues** | Toggle all spoken output (triggers + continuous speech) |
| **Flush Speech Buffer** (⌘L) | Stop speech immediately and discard queued utterances (enabled only while speech is active) |
| **Speech Settings…** | Opens **Settings → Speech** |

**Menu split (v1 parity + HIG)**

| Command | Menu | Purpose |
|---------|------|---------|
| **Speak Selected Text** | **Edit → Speech** | Read selected text in input or output (replaces v1 **Start Speaking**) |
| **Flush Speech Buffer** (⌘L) | **Audio** | Stop Savitar speech and clear its queue (continuous + trigger speech) |

Savitar 1 did not include **Stop Speaking** as a separate Savitar command — that was the macOS counterpart to **Start Speaking**. Queued speech is cleared with **Flush Speech Buffer**, not Stop Speaking.

### Speech settings reference

Open **Settings…** → **Speech**:

| Control | Description |
|---------|-------------|
| **Continuous speech enabled** | Master switch for reading world output aloud |
| **Voice** | Default English voice for continuous speech and **Speak Selected Text** |
| **Speaker button** | Plays a sample sentence with the selected voice |
| **Rate** | Slow (5) through Fast (20); **10** is normal speed. Affects continuous speech, trigger speech, and ad-hoc speech |

Voice and rate changes take effect on the next spoken utterance; you do not need to restart the app or reconnect to a world.

### Tips

- If nothing is spoken after enabling continuous speech, confirm **Mute Speaking Cues** is off and that the world is actually sending text to the output pane.
- Long bursts of output are spoken as they arrive; use **Flush Speech Buffer** (⌘L) to skip ahead when you have fallen behind.
- Importing Savitar 1 preferences preserves your continuous speech enabled flag, voice name, and rate from the v1 prefs file.

---

## More chapters (planned)

Story 9 in [Stories.md](Stories.md) tracks the remaining user-guide sections: worlds and sessions, input and macros, triggers and events, ANSI colors, appearance, and window management.
