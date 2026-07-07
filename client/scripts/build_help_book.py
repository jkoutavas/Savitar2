#!/usr/bin/env python3
"""Generate Savitar.help from docs/USER_GUIDE.md (Story 16).

Run from repo root:
  python3 client/scripts/build_help_book.py

Requires macOS `hiutil` to build the help index (Xcode Command Line Tools).
"""

from __future__ import annotations

import html
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
GUIDE_MD = REPO_ROOT / "docs" / "USER_GUIDE.md"
HELP_ROOT = REPO_ROOT / "client" / "Savitar2" / "resources" / "Savitar.help"
LOCALE_DIR = HELP_ROOT / "Contents" / "Resources" / "en.lproj"

ANCHOR_BY_TITLE = {
    "Getting started": "getting-started",
    "Speech": "speech",
    "Menus": "menus",
    "Events": "events",
    "Macros": "macros",
    "World Settings": "world-settings",
    "Privacy & usage statistics": "privacy",
    "Getting help": "getting-help",
    "ANSI colors": "ansi-colors",
    "Input & Display": "input-display",
    "Audio": "audio",
    "Updates": "updates",
    "More chapters (planned)": "planned",
}

CSS = """\
body {
  font: -apple-system-body;
  line-height: 1.45;
  margin: 1.25rem 2rem;
  color: #111;
}
h1 { font-size: 1.6rem; margin-top: 0; }
h2 {
  font-size: 1.25rem;
  margin-top: 2rem;
  border-bottom: 1px solid #ccc;
  padding-bottom: 0.25rem;
}
h3 { font-size: 1.05rem; margin-top: 1.25rem; }
h4 { font-size: 0.98rem; margin-top: 1rem; font-weight: 600; }
a { color: #0645ad; }
table { border-collapse: collapse; margin: 0.75rem 0; }
th, td { border: 1px solid #ccc; padding: 0.35rem 0.6rem; vertical-align: top; }
th { background: #f4f4f4; }
code { font-family: Menlo, monospace; font-size: 0.92em; }
ul, ol { padding-left: 1.4rem; }
.toc { background: #f8f8f8; border: 1px solid #ddd; padding: 0.75rem 1rem; margin: 1rem 0; }
"""


def slugify(title: str) -> str:
    s = title.lower().strip()
    s = re.sub(r"[^\w\s-]", "", s)
    s = re.sub(r"[\s_]+", "-", s)
    return s.strip("-") or "section"


def anchor_for_title(title: str) -> str:
    return ANCHOR_BY_TITLE.get(title, slugify(title))


def inline_format(text: str) -> str:
    text = html.escape(text, quote=False)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    return text


def parse_table(lines: list[str], start: int) -> tuple[str, int]:
    rows: list[list[str]] = []
    i = start
    while i < len(lines) and "|" in lines[i]:
        row = [cell.strip() for cell in lines[i].strip().strip("|").split("|")]
        rows.append(row)
        i += 1
    if len(rows) < 2:
        return "", start
    separator_line = lines[start + 1] if start + 1 < len(lines) else ""
    has_separator = bool(re.match(r"^[-: |]+$", separator_line.strip()))
    header, body = rows[0], rows[2:] if has_separator else rows[1:]
    parts = ["<table>"]
    parts.append("<thead><tr>" + "".join(f"<th>{inline_format(c)}</th>" for c in header) + "</tr></thead>")
    parts.append("<tbody>")
    for row in body:
        parts.append("<tr>" + "".join(f"<td>{inline_format(c)}</td>" for c in row) + "</tr>")
    parts.append("</tbody></table>")
    return "\n".join(parts), i


def markdown_to_body(md: str) -> tuple[str, list[tuple[str, str]]]:
    lines = md.splitlines()
    out: list[str] = []
    toc: list[tuple[str, str]] = []
    i = 0
    in_ul = False
    in_ol = False
    current_section_anchor = ""
    current_subsection_anchor = ""

    def close_lists() -> None:
        nonlocal in_ul, in_ol
        if in_ul:
            out.append("</ul>")
            in_ul = False
        if in_ol:
            out.append("</ol>")
            in_ol = False

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            close_lists()
            i += 1
            continue

        # Online-only metadata; keep in USER_GUIDE.md for GitHub but omit from the app bundle.
        if re.match(r"^_Last updated\b.*_$", stripped, re.IGNORECASE):
            i += 1
            continue

        if stripped == "---":
            close_lists()
            out.append("<hr/>")
            i += 1
            continue

        if stripped.startswith("|"):
            close_lists()
            table_html, i = parse_table(lines, i)
            if table_html:
                out.append(table_html)
            continue

        m = re.match(r"^(#{1,4})\s+(.+)$", stripped)
        if m:
            close_lists()
            level = len(m.group(1))
            title = m.group(2).strip()
            if level == 2:
                anchor = anchor_for_title(title)
                current_section_anchor = anchor
                current_subsection_anchor = ""
            elif level == 3 and current_section_anchor:
                anchor = f"{current_section_anchor}-{slugify(title)}"
                current_subsection_anchor = anchor
            elif level == 4 and current_subsection_anchor:
                anchor = f"{current_subsection_anchor}-{slugify(title)}"
            elif level == 4 and current_section_anchor:
                anchor = f"{current_section_anchor}-{slugify(title)}"
            else:
                anchor = anchor_for_title(title)
            tag = f"h{level}"
            if level == 2:
                toc.append((anchor, title))
            out.append(f'<{tag} id="{anchor}">{inline_format(title)}</{tag}>')
            i += 1
            continue

        if re.match(r"^[-*]\s+", stripped):
            if in_ol:
                out.append("</ol>")
                in_ol = False
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            item = re.sub(r"^[-*]\s+", "", stripped)
            out.append(f"<li>{inline_format(item)}</li>")
            i += 1
            continue

        if re.match(r"^\d+\.\s+", stripped):
            if in_ul:
                out.append("</ul>")
                in_ul = False
            if not in_ol:
                out.append("<ol>")
                in_ol = True
            item = re.sub(r"^\d+\.\s+", "", stripped)
            out.append(f"<li>{inline_format(item)}</li>")
            i += 1
            continue

        close_lists()
        out.append(f"<p>{inline_format(stripped)}</p>")
        i += 1

    close_lists()
    return "\n".join(out), toc


def build_index_html(body: str, toc: list[tuple[str, str]]) -> str:
    toc_items = "".join(f'<li><a href="#{a}">{html.escape(t)}</a></li>' for a, t in toc)
    toc_block = f'<nav class="toc" aria-label="Table of contents"><strong>Contents</strong><ul>{toc_items}</ul></nav>'
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <title>Savitar Help</title>
  <link rel="stylesheet" type="text/css" href="savitar-help.css"/>
  <meta name="AppleTitle" content="Savitar Help"/>
  <meta name="AppleIcon" content=""/>
</head>
<body>
  <a id="top" name="top"></a>
  <h1>Savitar Help</h1>
  <p>User guide for Savitar 2. Works offline in the app. For the latest draft chapters, see the project user guide on the web.</p>
  {toc_block}
  {body}
</body>
</html>
"""


def write_help_bundle_plist() -> None:
    plist = HELP_ROOT / "Contents" / "Info.plist"
    plist.parent.mkdir(parents=True, exist_ok=True)
    plist.write_text(
        """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.heynow.savitar.help</string>
  <key>CFBundleName</key>
  <string>Savitar Help</string>
  <key>CFBundlePackageType</key>
  <string>BNDL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>HPDBookAccessPaths</key>
  <array/>
  <key>HPDBookIndexPath</key>
  <string>Savitar.helpindex</string>
  <key>HPDBookTitle</key>
  <string>Savitar Help</string>
  <key>HPDBookTopicListCSSPath</key>
  <string>savitar-help.css</string>
  <key>HPDBookTopicListXHTMLPath</key>
  <string>index.html</string>
</dict>
</plist>
""",
        encoding="utf-8",
    )


def run_hiutil() -> None:
    index_path = LOCALE_DIR / "Savitar.helpindex"
    if index_path.exists():
        index_path.unlink()
    cmd = [
        "hiutil",
        "-a",
        "-C",
        "-s",
        "en",
        "-l",
        "en",
        "-f",
        str(index_path),
        str(LOCALE_DIR),
    ]
    subprocess.run(cmd, check=True)


def main() -> int:
    if not GUIDE_MD.is_file():
        print(f"error: missing {GUIDE_MD}", file=sys.stderr)
        return 1

    md = GUIDE_MD.read_text(encoding="utf-8")
    body, toc = markdown_to_body(md)
    LOCALE_DIR.mkdir(parents=True, exist_ok=True)
    write_help_bundle_plist()
    (LOCALE_DIR / "savitar-help.css").write_text(CSS, encoding="utf-8")
    (LOCALE_DIR / "index.html").write_text(build_index_html(body, toc), encoding="utf-8")

    try:
        run_hiutil()
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"warning: hiutil failed ({exc}); HTML help book still generated.", file=sys.stderr)
        return 0

    print(f"Wrote {HELP_ROOT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
