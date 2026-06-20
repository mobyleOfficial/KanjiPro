#!/usr/bin/env python3
"""Generate assets/data/kanji.json from kanjiapi.dev (KANJIDIC2, CC BY-SA 4.0)."""
import json, pathlib, sys, time
import requests

API = "https://kanjiapi.dev/v1"
LEVELS = {"jlpt-5": "n5", "jlpt-4": "n4", "jlpt-3": "n3", "jlpt-2": "n2", "jlpt-1": "n1"}
OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "data" / "kanji.json"

def fetch(path):
    r = requests.get(f"{API}/{path}", timeout=30)
    r.raise_for_status()
    return r.json()

def main():
    out = []
    seen = set()
    for grade, level in LEVELS.items():
        literals = fetch(f"kanji/{grade}")
        for lit in literals:
            if lit in seen:
                continue
            seen.add(lit)
            d = fetch(f"kanji/{lit}")
            out.append({
                "literal": d["kanji"],
                "jlpt": level,
                "on_readings": d.get("on_readings", []),
                "kun_readings": d.get("kun_readings", []),
                "meanings": d.get("meanings", []),
                "stroke_count": d.get("stroke_count", 0),
            })
            time.sleep(0.02)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=0))
    print(f"wrote {len(out)} kanji -> {OUT}", file=sys.stderr)

if __name__ == "__main__":
    main()
