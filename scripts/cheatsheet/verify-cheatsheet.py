#!/usr/bin/env python3
"""Checks that every key on the cheatsheet exists in a keymap dump from dump-keymaps.lua.

Usage: verify-cheatsheet.py MAPS.tsv

Exits 1 if an entry is missing. Pattern entries such as m{a-z} and insert-mode completion keys
can't be matched against the dump, so they are skipped and counted. Keep those correct by hand.
"""
import importlib.util
import pathlib
import re
import sys

# The hyphen in the file name rules out a normal import statement.
sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location(
    "build_cheatsheet", pathlib.Path(__file__).with_name("build-cheatsheet.py")
)
_cheatsheet = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_cheatsheet)
P1, P2 = _cheatsheet.P1, _cheatsheet.P2

# Attached per buffer (gitsigns, TypeScript, test files, package.json, Markdown), so they aren't in
# a global dump. Sources: plugins/git.lua and plugins/which-key/setup.lua. Update them together.
BUFFER_LOCAL = {
    "]c", "[c", "ih", "<leader>gm",
    "<leader>ghs", "<leader>ghr", "<leader>ghS", "<leader>ghR", "<leader>ghu", "<leader>ghp", "<leader>ghd", "<leader>ght",
    "<leader>co", "<leader>ci", "<leader>cu", "<leader>cF", "<leader>ce",
    "<leader>jj", "<leader>jf", "<leader>jl", "<leader>js", "<leader>jo", "<leader>ji",
    "<leader>nc", "<leader>nd", "<leader>ni", "<leader>nu", "<leader>nr", "<leader>ns", "<leader>nh",
    "<leader>am",
}
NAMED_KEYS = {"CR", "BS", "Tab", "F12", "Up", "Down", "Left", "Right"}


def to_lhs(tokens):
    out = ""
    for i, tok in enumerate(tokens):
        if tok == "SL":
            out += "/"
        elif tok == "SPC":
            out += "<leader>" if i == 0 else " "
        elif tok == "C-\\":
            out += "<C-Bslash>"
        elif tok == "<":
            out += "<lt>"
        elif tok in NAMED_KEYS:
            out += f"<{tok}>"
        elif re.fullmatch(r"[CMSD]-.+", tok):
            out += "<%s>" % tok.replace("LeftClick", "LeftMouse")
        else:
            out += tok.replace("SPC", " ")
    return out


def expand(keys):
    """Turns "SPC g h s / h r" into [SPC g h s], [SPC g h r]: an alternative replaces the trailing tokens."""
    groups, current, is_range = [], [], False
    for tok in keys.split(" "):
        if tok in ("/", "·", "…"):
            is_range = is_range or tok == "…"
            groups.append(current)
            current = []
        else:
            current.append(tok)
    groups.append(current)

    first = groups[0]
    alternatives = [first]
    for group in groups[1:]:
        if is_range:  # "M-1 … 9" keeps the modifier of the first key
            prefix = re.match(r"(?:[CMSD]-)?", first[-1]).group()
            alternatives.append(first[:-1] + [prefix + group[-1]])
        elif group[0] == "SPC":
            alternatives.append(group)
        else:
            alternatives.append(first[: len(first) - len(group)] + group)

    expanded = []
    for tokens in alternatives:
        last = tokens[-1]
        if "/" in last and len(last) > 1 and "{" not in last:  # "C-h/j/k/l"
            parts = last.split("/")
            head, options = parts[0][:-1], [parts[0][-1]] + parts[1:]
            expanded += [tokens[:-1] + [head + option] for option in options]
        else:
            expanded.append(tokens)
    return expanded


def main():
    known = {key.lower() for key in BUFFER_LOCAL}
    with open(sys.argv[1], encoding="utf-8") as dump:
        for line in dump:
            known.add(line.rstrip("\n").split("\t")[1].lower())

    checked = missing = skipped = 0
    for page in (P1, P2):
        for column in page:
            for _, _, rows in column:
                for keys, desc, modes in rows:
                    if "i" in modes.split() and keys != "C-s":
                        skipped += 1
                        continue
                    for tokens in expand(keys):
                        lhs = to_lhs(tokens)
                        if "{" in lhs or lhs == "m0-9":
                            skipped += 1
                            continue
                        checked += 1
                        if lhs.lower() not in known:
                            missing += 1
                            print(f"NOT IN CONFIG: {lhs!r} from {keys!r} ({desc})")

    print(f"checked={checked} missing={missing} skipped={skipped}")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
