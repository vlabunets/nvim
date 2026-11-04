#!/usr/bin/env python3
"""Prints the cheatsheet HTML; rebuild-cheatsheet.sh turns it into the PDF. The entries are maintained by hand.

Key syntax: spaces separate key caps. "/", "·" and "…" render as separators, and SL is a literal "/" key.
"""
import html
import sys

GREEN, BLUE, RED, PURPLE, ORANGE, TEAL, GREY, YELLOW = (
    "#6a9a4c", "#3f8fc4", "#d9534f", "#b57edc", "#e8912d", "#3fb8a0", "#6e7681", "#e0b84c",
)

P1 = [
    [
        ("Essentials", BLUE, [
            ("C-s", "Format and save file", "n i"),
            ("CR", "Clear search highlight", ""),
            ("H / BS", "First non-blank char of line", ""),
            ("x / X", "Delete char (no yank)", "n v"),
            ("p", "Paste over selection, keep register", "v"),
            ("J / K", "Move selection down / up", "v"),
            ("< / >", "Indent, keep selection", "v"),
            ("` / M-`", "lowercase / UPPERCASE selection", "v"),
            ("gx", "Open URL / path under cursor", ""),
            ("M-= / M--", "Font size + / − (GUI)", ""),
            ("[SPC / ]SPC", "Add empty line above / below", ""),
            ("SPC q", "Toggle quickfix list", ""),
            ("SPC , / SPC .", "Prev / next quickfix item", ""),
            ("SPC s", "Sort lines", "v"),
        ]),
        ("Buffers", TEAL, [
            ("]] / [[", "Next / prev buffer", ""),
            ("gn / gm", "Next / prev buffer (alt)", ""),
            ("M-1 … 9", "Go to buffer 1–9", ""),
            ("Q / D-w", "Close buffer", ""),
            ("SPC b p", "Pick buffer", ""),
            ("SPC b P", "Pin / unpin buffer", ""),
            ("SPC b c", "Close all but current", ""),
            ("SPC b l / b r", "Close buffers left / right", ""),
            ("SPC b f", "First buffer", ""),
            ("SPC b n / b b", "Move buffer next / back", ""),
            ("SPC b s d/e/r", "Sort by dir / ext / relative dir", ""),
        ]),
    ],
    [
        ("Windows & Splits", PURPLE, [
            ("C-h/j/k/l", "Go to split (also tmux / WezTerm)", ""),
            ("M-h/j/k/l", "Resize split", ""),
            ("SPC SPC h/j/k/l", "Swap buffer with split", ""),
            ("C-\\", "Previous split", ""),
            ("SPC v / SPC V", "Split right / below", ""),
            ("SPC = / SPC -", "Resize +5 / −5", ""),
            ("SPC z / SPC Z", "Zen mode / Zoom mode", ""),
            ("F12", "Toggle terminal", "n t"),
        ]),
        ("Harpoon", ORANGE, [
            ("SPC H", "Add file", ""),
            ("SPC h", "Menu", ""),
            ("SPC 1 … 4", "Jump to file 1–4", ""),
            ("SPC [ / SPC ]", "Prev / next file", ""),
        ]),
        ("Folds", GREY, [
            ("zR / zM", "Open / close all folds", ""),
            ("zr", "Open all except imports etc.", ""),
            ("zm", "Fold one more level", ""),
            ("K", "Peek folded lines", ""),
        ]),
        ("Marks", TEAL, [
            ("m{a-z}", "Set mark", ""),
            ("m,", "Set next free mark", ""),
            ("m;", "Toggle mark on line", ""),
            ("m] / m[", "Next / prev mark", ""),
            ("m:", "Preview mark", ""),
            ("m0-9", "Set bookmark group 0–9", ""),
            ("dm{x} / dm- / dmSPC", "Delete mark / line / buffer marks", ""),
        ]),
    ],
    [
        ("Files & Search", YELLOW, [
            ("C-p", "Smart file finder", ""),
            ("C-e", "File explorer", ""),
            ("SPC y", "Yazi at current file", "n v"),
            ("SPC c w", "Yazi at working directory", ""),
            ("C-Up", "Resume last Yazi session", ""),
            ("SPC s f", "Files", ""),
            ("SPC s h", "Recent files", ""),
            ("SPC s b", "Buffers", ""),
            ("SPC s g", "Git grep", ""),
            ("SPC s o", "Grep open buffers", ""),
            ("SPC p w", "Grep word under cursor", "n v"),
            ("SPC s s / s S", "Document / workspace symbols", ""),
            ("SPC s t / s T", "Todo / Todo-Fix-Fixme", ""),
            ("SPC s q", "Quickfix list", ""),
            ("SPC s H", "Command history", ""),
            ("SPC s SL", "Search history", ""),
            ("SPC s d", "Dotfiles", ""),
            ("SPC s c", "Color schemes", ""),
            ("SPC g f", "Git files", ""),
            ("SPC p l", "Projects", ""),
        ]),
        ("Motion", TEAL, [
            ("s", "Flash jump", "n v o"),
            ("S", "Flash Treesitter select", "n o"),
            ("]t / [t", "Next / prev todo comment", ""),
            ("]f / [f", "Next / prev function start", ""),
            ("]m / [m", "Next / prev class start", ""),
            ("]} / [{", "Next / prev JSX element", ""),
        ]),
    ],
    [
        ("LSP & Code", GREEN, [
            ("gd", "Go to definition — or CSS rule for a class in HTML templates", ""),
            ("gr", "References", ""),
            ("gy", "Type definition", ""),
            ("gi", "Implementation", ""),
            ("K", "Hover (peek fold when on a fold)", ""),
            ("L", "Signature help", ""),
            ("gl", "Line diagnostics", ""),
            ("]g / [g", "Next / prev diagnostic + popup", ""),
            ("SPC c a", "Code action", "n v"),
            ("C-Space", "Code action", ""),
            ("SPC c r", "Rename symbol", ""),
            ("SPC c R", "Rename file", ""),
            ("SPC c f / SPC f", "Format file / range", "n v"),
            ("SPC c t", "Toggle format on save", ""),
            ("SPC l", "Lint file", ""),
            ("SPC c d", "Diagnostics list", ""),
            ("SPC c U", "Toggle symbol usage", ""),
            ("SPC c v", "Tailwind CSS values", ""),
            ("SPC c l i/r/s/S", "LSP info / restart / stop / start", ""),
            ("SPC c m", "Mason", ""),
        ]),
        ("TypeScript Buffers", BLUE, [
            ("SPC c o", "Organize imports", ""),
            ("SPC c i", "Add missing imports", ""),
            ("SPC c u", "Remove unused code", ""),
            ("SPC c F", "Fix all", ""),
            ("SPC c e", "Workspace errors (TSC)", ""),
        ]),
        ("Test Files (Vitest)", TEAL, [
            ("SPC j j / j f", "Nearest test / file", ""),
            ("SPC j l / j s", "Run last / stop", ""),
            ("SPC j o / j i", "Output / summary panel", ""),
        ]),
    ],
    [
        ("Completion & Copilot", ORANGE, [
            ("Tab", "Accept · next snippet field · apply Copilot NES", "i"),
            ("S-Tab", "Prev item / snippet field", "i"),
            ("C-Space", "Show completion", "i"),
            ("S-j / S-k", "Scroll docs down / up", "i"),
            ("Tab", "Jump to / apply Copilot NES suggestion", ""),
        ]),
        ("Git", RED, [
            ("SPC g g", "Lazygit", ""),
            ("SPC g l a / l c", "Lazygit log / file history", ""),
            ("SPC g l A / l C", "Log / file commits (picker)", ""),
            ("SPC g s / g S", "Status", ""),
            ("SPC g a / g A", "Add file / add all", ""),
            ("SPC g b", "Blame", ""),
            ("SPC g m", "Blame line (full)", ""),
            ("SPC g d", "Diff file", ""),
            ("SPC g D", "Diffview open", ""),
            ("SPC g L", "Copy URL of selection", "v"),
            ("SPC g i / g p", "GitHub issues / PRs", ""),
            ("]c / [c", "Next / prev hunk", ""),
            ("SPC g h s / h r", "Stage / reset hunk", ""),
            ("SPC g h S / h R", "Stage / reset buffer", ""),
            ("SPC g h u", "Undo stage hunk", ""),
            ("SPC g h p / h d", "Preview / diff hunk", ""),
            ("SPC g h t", "Toggle deleted lines", ""),
            ("ih", "Hunk text object", "o x"),
        ]),
        ("Debug (DAP)", "#c9558f", [
            ("SPC d b / d B", "Breakpoint / conditional", ""),
            ("SPC d d / d a", "Continue", ""),
            ("SPC d i / d O / d o", "Step into / over / out", ""),
            ("SPC d t", "Terminate", ""),
            ("SPC d u / d c", "Open / close UI", ""),
            ("SPC d h", "Evaluate", ""),
            ("SPC d r / d s / d w", "REPL / scopes / watches", ""),
        ]),
    ],
]

P2 = [
    [
        ("Editing", GREEN, [
            ("ys{motion}{c}", "Surround motion (yss = line)", ""),
            ("cs{old}{new}", "Change surrounding", ""),
            ("ds{c}", "Delete surrounding", ""),
            ("gS", "Surround selection (new lines)", "v"),
            ("gcc / gc{motion}", "Comment line / motion", "n v"),
            ("gbc / gb{motion}", "Block comment", "n v"),
            ("gco / gcO / gcA", "Comment below / above / at EOL", ""),
            ("ga / gA", "Align / with preview", "n v"),
            ("gJ", "Split / join block", ""),
            ("gp{motion}", "Insert debug print", "n v"),
            ("C-a / C-x", "Smart increment / decrement", "n v"),
            ("~", "Swap with next parameter", ""),
            ("SPC a c", "Comment box", "n v"),
            ("SPC a s a / a s e", "Add / edit snippet", "n v"),
            ("SPC a l l / a l r", "Toggle number / relativenumber", ""),
        ]),
    ],
    [
        ("Text Case (gu + key)", YELLOW, [
            ("gu c · p · s · k", "camelCase · PascalCase · snake_case · kebab-case", "n v"),
            ("gu n · d · t · SL", "CONSTANT · dot.case · Title Case · path/case", "n v"),
            ("gu u · l · SPC", "UPPER · lower · phrase case", "n v"),
            ("gu {C,P,S,K,…}", "Uppercase key = LSP rename to that case", ""),
            ("guo{key}{motion}", "Operator: convert over a motion", ""),
        ]),
        ("Text Objects", ORANGE, [
            ("af / if", "Function outer / inner", "o x"),
            ("ac / ic", "Class outer / inner", "o x"),
            ("a{x} / i{x}", "mini.ai around / inside", "o x"),
            ("an · in · al · il", "Next / last text object", "o x"),
            ("g] / g[", "Move to edge of \"around\"", "n o x"),
            ("]n · [n · ]N · [N", "Select next/prev (sibling) node", "x"),
            ("CR / BS", "Select parent / child node", "x"),
        ]),
    ],
    [
        ("Multi-Cursor", BLUE, [
            ("Up / Down", "Add cursor above / below", "n v"),
            ("SPC Up / SPC Down", "Skip line above / below", "n v"),
            ("SPC m", "Add cursor at next match", "n v"),
            ("Left / Right", "Rotate main cursor", "n v"),
            ("SPC x", "Delete main cursor", "n v"),
            ("C-LeftClick", "Add / remove cursor", ""),
            ("SPC g v", "Restore cursors", ""),
        ]),
    ],
    [
        ("AI · Avante", PURPLE, [
            ("SPC a a", "Ask", "n v"),
            ("SPC a e", "Edit selection", "v"),
            ("SPC a n", "New ask", "n v"),
            ("SPC a t / a f", "Toggle / focus sidebar", ""),
            ("SPC a z", "Zen mode", "n v"),
            ("SPC a r", "Refresh", ""),
            ("SPC a B", "Add all open buffers", ""),
            ("SPC a C", "Toggle selection", ""),
            ("SPC a ?", "Select model", ""),
            ("SPC a h", "History", ""),
            ("SPC a s / a S", "Toggle suggestion / stop", ""),
            ("SPC a M / a o", "ACP mode / model", ""),
            ("SPC a R / a d", "Repo map / debug", ""),
        ]),
        ("Project, Sessions & Refactor", YELLOW, [
            ("SPC p s s / p s l", "Save / load session", ""),
            ("SPC p s L / p s m", "Load last session / commands", ""),
            ("SPC p r r", "Search & replace (grug-far)", ""),
            ("SPC p r w / p r W", "Replace word under cursor", "n v"),
            ("SPC p r f", "Replace in current file", "n v"),
            ("SPC p r a", "Refactor with ast-grep", ""),
        ]),
    ],
    [
        ("Tools & EcoVim", GREEN, [
            ("SPC SL SL", "Dashboard", ""),
            ("SPC SL c", "Open config", ""),
            ("SPC SL l / SL i / SL u", "Lazy / manage / update plugins", ""),
            ("SPC D", "Database (sqlit)", ""),
            ("SPC n c/d/i/u/r", "NPM: change / delete / install / update / reinstall (package.json)", ""),
            ("SPC n s / n h", "NPM: show / hide versions (package.json)", ""),
            ("SPC a m", "Markdown preview (markdown)", ""),
        ]),
    ],
]

MODE_CLASS = {"n": "n", "v": "v", "i": "i", "o": "o", "t": "t", "x": "x"}


def caps(keys):
    out = []
    for tok in keys.split(" "):
        if tok in ("/", "·", "…"):
            cls = "sep"
            out.append(f'<span class="{cls}">{html.escape(tok)}</span>')
        elif tok == "SL":
            out.append("<kbd>/</kbd>")
        elif tok == "SPC":
            out.append('<kbd class="spc">SPC</kbd>')
        else:
            out.append(f"<kbd>{html.escape(tok)}</kbd>")
    return "".join(out)


def modes(m):
    return "".join(f' <span class="m {MODE_CLASS[x]}">{x}</span>' for x in m.split())


def section(title, color, rows):
    body = "".join(
        f'<tr><td class="k">{caps(k)}</td><td class="d">{html.escape(d)}{modes(m)}</td></tr>' for k, d, m in rows
    )
    return f'<section style="--c:{color}"><h2>{html.escape(title)}</h2><table>{body}</table></section>'


def grid(cols):
    return '<div class="grid">' + "".join(
        '<div class="col">' + "".join(section(*s) for s in col) + "</div>" for col in cols
    ) + "</div>"


LEGEND = "".join(f'<span class="m {m}">{m}</span> {name} ' for m, name in [
    ("n", "normal"), ("v", "visual"), ("i", "insert"), ("o", "operator"), ("t", "terminal"), ("x", "visual only"),
])

CSS = """
@page { size: A4 landscape; margin: 11mm 12mm; }
* { box-sizing: border-box; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
html, body { margin: 0; background: #fff; color: #1b1f24; font: 8pt/1.22 "Helvetica Neue", Helvetica, Arial, sans-serif; }
header { display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #1b1f24; padding-bottom: 5px; margin-bottom: 5px; font-size: 7pt; color: #57606a; }
h1 { font-size: 15pt; margin: 0; color: #1b1f24; white-space: nowrap; }
header .legend { margin-left: auto; white-space: nowrap; }
.grid { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 9px; align-items: start; }
.page2 { break-before: page; }
.col { display: flex; flex-direction: column; gap: 7px; min-width: 0; }
section { background: #f6f7f8; border-top: 1.5px solid var(--c); padding: 3px 4px 3px; border-radius: 0 0 3px 3px; }
h2 { font-size: 8.5pt; margin: 0 0 2px; letter-spacing: .03em; text-transform: uppercase; }
table { border-collapse: collapse; width: 100%; }
td { vertical-align: top; padding: 1.2px 0; border-top: .5px solid #e4e6e9; }
tr:first-child td { border-top: 0; }
td.k { white-space: nowrap; padding-right: 5px; width: 1%; }
td.d { font-size: 7.4pt; }
kbd { font: 700 6.5pt/1 Menlo, monospace; background: #fff; border: .5px solid #b6bcc4; border-radius: 2px; padding: 1px 2px; margin-right: 1px; display: inline-block; }
kbd.spc { background: #24292f; color: #fff; border-color: #24292f; }
.sep { color: #6e7681; font-size: 6.5pt; margin: 0 1.5px; }
.m { display: inline-block; font: 700 5.5pt/1 Menlo, monospace; color: #fff; border-radius: 1.5px; padding: 1px 2px; }
.m.n { background: #3f8fc4; } .m.v { background: #b57edc; } .m.i { background: #d9534f; }
.m.o { background: #5f8d3e; } .m.t { background: #6e7681; } .m.x { background: #b57edc; }
footer { color: #6e7681; font-size: 6.8pt; margin-top: 7px; }
"""

def render(date):
    return f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><title>EcoVim Keymaps</title><style>{CSS}</style></head><body>
<header><h1>EcoVim · Keymaps</h1>
<span><kbd class="spc">SPC</kbd> = leader · <kbd>C-</kbd> Ctrl <kbd>M-</kbd> Alt/Option <kbd>S-</kbd> Shift <kbd>D-</kbd> Cmd · Cmd variants: <kbd>D-s</kbd> save, <kbd>D-p</kbd> files, <kbd>D-e</kbd> explorer, <kbd>D-w</kbd> close</span>
<span class="legend">modes (normal unless tagged): {LEGEND}</span></header>
{grid(P1)}
<div class="page2">{grid(P2)}
<footer>Checked against the live config (all plugins loaded) · {date} · Press <kbd class="spc">SPC</kbd> and wait for which-key to browse everything.</footer></div>
</body></html>"""


if __name__ == "__main__":
    print(render(sys.argv[1]))
