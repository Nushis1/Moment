#!/usr/bin/env python3
"""Regenerate Moment/Localizable.xcstrings and InfoPlist.xcstrings from tools/pl.py."""
import json, pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
from pl import PL

def catalog(entries):
    return {
        "sourceLanguage": "en",
        "strings": {
            key: {"extractionState": "manual",
                  "localizations": {"pl": {"stringUnit": {"state": "translated", "value": value}}}}
            for key, value in sorted(entries.items())
        },
        "version": "1.0",
    }

(ROOT / "Moment" / "Localizable.xcstrings").write_text(json.dumps(catalog(PL), ensure_ascii=False, indent=2) + "\n")
info = {"sourceLanguage": "en", "strings": {"NSFaceIDUsageDescription": {"extractionState": "manual", "localizations": {
    "en": {"stringUnit": {"state": "translated", "value": "MOMENT uses Face ID to lock your private notes and decisions."}},
    "pl": {"stringUnit": {"state": "translated", "value": "MOMENT używa Face ID do zablokowania twoich prywatnych notatek i decyzji."}}}}}, "version": "1.0"}
(ROOT / "Moment" / "InfoPlist.xcstrings").write_text(json.dumps(info, ensure_ascii=False, indent=2) + "\n")
print(len(PL), "keys")
