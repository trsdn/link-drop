<p align="center">
  <img src="icon.svg" width="128" height="128" alt="LinkDrop icon">
</p>

<h1 align="center">LinkDrop</h1>

<p align="center">
  <strong>Instantly save links from your clipboard as files on macOS.</strong>
</p>

<p align="center">
  <a href="https://github.com/trsdn/link-drop/releases/latest"><img src="https://img.shields.io/github/v/release/trsdn/link-drop?style=flat-square&color=blue" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/trsdn/link-drop?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-lightgrey?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/binary-224%20KB-green?style=flat-square" alt="Size">
  <img src="https://img.shields.io/badge/code-213%20lines-orange?style=flat-square" alt="Lines of code">
  <img src="https://img.shields.io/badge/swift-SwiftUI-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift">
  <a href="https://trsdn.github.io/link-drop/"><img src="https://img.shields.io/badge/website-trsdn.github.io%2Flink--drop-blue?style=flat-square&logo=github" alt="Website"></a>
</p>

---

## The Problem

You're researching something, jumping between browser tabs, Slack messages, documents. You find a link you want to keep. What do you do?

On macOS, creating a simple link file is **surprisingly hard**. There's no "Save Link As..." in most apps. You can't just right-click and create a shortcut like on other platforms. You end up pasting URLs into notes, bookmarks you'll never revisit, or text files with no structure.

If you organize things in folders — projects, research, bookmarks by topic — you want **links as files**. Clickable, movable, sortable. Just like any other file in Finder.

## The Solution

**LinkDrop** does one thing and does it well:

1. Copy a URL to your clipboard
2. Open LinkDrop
3. Hit <kbd>Cmd</kbd>+<kbd>Return</kbd>

That's it. A `.url` shortcut file appears in your Downloads folder (or wherever you configure). Double-click it anytime to open the link in your browser.

<p align="center">
  <img src="screenshots/screenshot-main.png" width="500" alt="LinkDrop main window">
</p>

## Features

- **Clipboard-first** — Automatically reads your clipboard on launch. No pasting needed.
- **Smart naming** — Derives a sensible filename from the URL (e.g., `github.com – claude-code.url`).
- **Works with everything** — Web URLs, `file://` paths, deep links. If it's a URL, LinkDrop handles it.
- **Configurable save folder** — Defaults to `~/Downloads`. Change it in Settings (<kbd>Cmd</kbd>+<kbd>,</kbd>).
- **Native macOS** — Built with SwiftUI. No Electron, no web views, no runtime dependencies.

<p align="center">
  <img src="screenshots/screenshot-settings.png" width="500" alt="LinkDrop settings">
</p>

## Tiny Footprint

| Metric | Value |
|--------|-------|
| Binary size | **224 KB** |
| App bundle | **1.5 MB** (mostly the icon) |
| Source code | **213 lines** — single Swift file |
| Memory usage | **~15 MB** |
| Dependencies | **Zero** — just SwiftUI and AppKit |

No background processes. No auto-updates. No telemetry. Opens instantly, does its job, quits when you close it.

## Install

### Download

Grab the latest `.app` from [Releases](https://github.com/trsdn/link-drop/releases/latest), unzip, and drag to `/Applications`.

### Build from Source

Requires Xcode Command Line Tools and macOS 13+.

```bash
git clone https://github.com/trsdn/link-drop.git
cd link-drop
make build
make install  # copies to /Applications
```

## How .url Files Work

LinkDrop creates standard [`.url` internet shortcut files](https://en.wikipedia.org/wiki/URL_shortcut):

```ini
[InternetShortcut]
URL=https://github.com/trsdn/link-drop
```

Double-clicking a `.url` file in Finder opens the URL in your default browser. These files are tiny (under 100 bytes), cross-platform compatible, and work great with Spotlight search.

## License

[MIT](LICENSE)
