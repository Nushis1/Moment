#!/usr/bin/env python3
"""List UI string literals found in Moment/**/*.swift and compare them with Localizable.xcstrings.

Usage: python3 tools/l10n_extract.py            # report missing / unused keys (app)
       python3 tools/l10n_extract.py --core     # same for MomentCore engine texts
       python3 tools/l10n_extract.py --all      # print every candidate literal
"""
import json, re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
CORE = "--core" in sys.argv
SRC = ROOT / "MomentCore" / "Sources" / "MomentCore" if CORE else ROOT / "Moment"
CATALOG = (SRC / "Resources" if CORE else SRC) / "Localizable.xcstrings"
SKIP_FILES = {"Lexicons.swift", "ReplyTemplates.swift"} if CORE else {"DemoData.swift"}

IGNORE = {
    "MomentBackground","MomentSurface","MomentPrimary","MomentSecondary","MomentSeparator","AccentColor",
    "MomentAccentFill","MomentPositive","MomentCaution","en_US_POSIX","yyyy-MM-dd","CFBundleShortVersionString",
    "MOMENT-export-%@.json","–","/","Alex","Sam","Worth pausing before I acted.","Moment","Decisions","Outcome","?","Empty",". ",".","!","ł","'","\\u{2019}","ąćęłńóśźżĄĆĘŁŃÓŚŹŻ",
}

def literals(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == "/" and text[i:i+2] == "//":
            j = text.find("\n", i); i = n if j < 0 else j; continue
        if c == "\"":
            if text[i:i+3] == "\"\"\"":
                j = text.find("\"\"\"", i+3); i = j + 3; continue
            j, buf = i + 1, ""
            while j < n and text[j] != "\"":
                if text[j] == "\\":
                    if text[j+1] == "(":
                        depth, k = 1, j + 2
                        while depth:
                            depth += {"(":1, ")":-1}.get(text[k], 0); k += 1
                        buf += "%@"; j = k; continue
                    buf += text[j:j+2]; j += 2; continue
                buf += text[j]; j += 1
            out.append(buf); i = j + 1; continue
        i += 1
    return out

def candidates():
    found = {}
    for path in sorted(SRC.rglob("*.swift")):
        if path.name in SKIP_FILES: continue
        for lit in literals(path.read_text()):
            lit = lit.replace("\\\x27", "\x27").replace("\\\"", "\"")
            if lit in IGNORE or not lit.strip(): continue
            if re.fullmatch(r"[a-z0-9_.]+", lit): continue          # SF Symbols, keys
            if re.fullmatch(r"[a-z][A-Za-z0-9.]*", lit): continue
            if re.fullmatch(r"[%@ /\d]*", lit): continue
            found.setdefault(lit, set()).add(path.name)
    return found

def norm(key):
    return re.sub(r"%(lld|d|@|ld)", "%@", key)

if __name__ == "__main__":
    cands = candidates()
    if "--all" in sys.argv:
        for k in cands: print(k)
        sys.exit(0)
    cat = json.loads(CATALOG.read_text())["strings"] if CATALOG.exists() else {}
    have = {norm(k): k for k in cat}
    missing = [k for k in cands if norm(k) not in have]
    unused = [k for k in cat if norm(k) not in {norm(c) for c in cands}]
    print(f"{len(cands)} literals, {len(cat)} catalog keys")
    print("MISSING:", *missing, sep="\n  ") if missing else print("No missing keys.")
    print("UNUSED:", *unused, sep="\n  ") if unused else print("No unused keys.")
    sys.exit(1 if missing else 0)
