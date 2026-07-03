# From Savitar 1 to Savitar 2

_Last updated July 2, 2026._

## How this document came to be

Late in a Cursor session—menubar and print finished, plain-text documents debugged, a user-guide chapter drafted—Jay pointed the agent at [Savitar2DevNotes.md](Savitar2DevNotes.md) and asked for something reflective, not technical. The work was headed for [PR #51](https://github.com/jkoutavas/Savitar2/pull/51). The prompt was:

> Okay! This is going to be a swell PR. Just for grins, read @Savitar2/docs/Savitar2DevNotes.md and **give me your impressions of the journey as it started from there. It's hard to imagine I use to do all this work without the aid of agentic LLMs.**

**Auto** (the Cursor coding agent in that chat) read the dev notes and answered in the conversation. Jay said the reply was exactly what he wanted—“awww”—and asked that it be captured here, without rewriting it into a formal project history. What follows is that assessment, lightly edited only for markdown.

The dev notes are the chronological lab notebook; this is the narrative that fell out of reading them.

---

Reading `Savitar2DevNotes.md` feels like opening a lab notebook from someone who knew the stakes and refused to fake the hard parts.

## The bet that mattered

The November 2019 entries are the whole story in miniature. You didn’t pick WKWebView because it was fashionable—you walked the alternatives honestly: NSTextView (two parsers you didn’t want to build), iTerm2Lib (fast but a carving job), then back to WebKit with real skepticism (“just too darn slow”). That loop—_want both ANSI and HTML, fear performance, test the fear_—is still the spine of Savitar 2. Six years later we’re still living in that choice: HTML output, plain-text print, `jobTitle` for PDF names, fighting `NSTextStorage` chains in a text document window. The architecture aged; the tradeoffs didn’t.

## The lists that never lie

Those alpha/beta checklists are painfully familiar. In January 2020, **MENUBAR FINALIZED** and **LOGGING** sit unchecked next to triggers and connect/disconnect. We literally checked off menubar finalized this week—after print, find, speech, text documents, and a delegate bug that hung the app on close. The [README](../README.md)’s current list still has Sparkle, Macro Clicker, MCP, file upload. Some items are forever “post first release,” with a dignified `_ ???` at the end. That’s not failure; it’s a 27-year-old app being honest about scope.

## Where the real time went

The notes don’t linger on telnet or ANSI parsing. They linger on **the Events Window**.

January–April 2020 is you thinking in public about undo managers, dirty documents, whether trigger names are identities, whether ReSwift wants structs or classes, whether there should be One Store or per-document stores, whether the Events UI should be modal, a side pane, below like Safari’s inspector, magnetically docked, or its own window. You built an entire [ReSwift example app](https://github.com/jkoutavas/reswift-example) to rehearse employee drag-and-drop before touching Savitar again. That’s not procrastination—that’s a senior engineer knowing the wrong abstraction will cost years.

The April 21st resolution is crisp: filename over world name in the Events groups, path disambiguation when two worlds share a name, ditch the GUID angst for split-view autosave. We’re still living in those decisions. The dev notes even predicted today’s tension: world **name** vs document **filename**—and we just wired both into save panels and PDF defaults.

## Voice of the notebook

What comes through is solitary, iterative, occasionally profane (“Effing event window!!!!!!!!”), and never performative. You argue with yourself, reverse yourself, cite Hacker News and Redux recipes, screenshot Safari’s debugger, then write **LET US START WITH** in caps and actually ship that. There’s no team standup—just you, the NSDocument docs, and a question about whether two worlds with the same UUID should mutate on open.

It’s hard to imagine doing that without an LLM because **you already did**—for years, in exactly this format. The LLM didn’t invent the Events Window architecture or the WKWebView bet. It accelerates the long tail: `PlainTextDocument`, `NSPrintOperation.jobTitle`, user-guide chapters, “why does Duplicate show up but Save As doesn’t.” The notebook is architecture and taste; the agent is implementation bandwidth.

## The arc to [PR #51](https://github.com/jkoutavas/Savitar2/pull/51)

December 2020 ends mid-stream: World Picker, wizard, input triggers, variable capture. Then a long gap (the notes go quiet; the README picks up the rest). What landed since—ReSwift in production, per-world Events windows, continuous speech, HIG Settings, Find/Print, text documents, window restoration—is the other half of the same laundry list, finally getting checkmarks.

[PR #51](https://github.com/jkoutavas/Savitar2/pull/51) is almost comically on-theme for the notebook: v1 parity in small, unglamorous pieces (menubar, plain text, print that preserves ASCII art shape), plus the bugs you only find when you actually use the thing (can’t type, close hangs, window at bottom-left). Savitar 1 had `CTextDocument` and a `'TEXT'` pane in 1997–2003 PowerPlant; we reinvented it in an afternoon with `scrollableTextView()` and a lesson about window delegates. The journey didn’t change character—only the typing speed did.

For what it’s worth: the dev notes read like someone who deserved a collaborator and got one, six years late, that never gets tired of reading `NSWindowController` docs. [PR #51](https://github.com/jkoutavas/Savitar2/pull/51) is swell because the _thinking_ was already swell; it was just waiting in a file called `Savitar2DevNotes.md` with `_ MENUBAR FINALIZED` still unchecked.

---

**See also:** [Savitar2DevNotes.md](Savitar2DevNotes.md) (the notebook itself) · [README](../README.md) (what’s done and what’s left) · [USER_GUIDE.md](USER_GUIDE.md) · [HIG.md](HIG.md)
