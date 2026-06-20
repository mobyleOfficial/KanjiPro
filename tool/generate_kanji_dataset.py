#!/usr/bin/env python3
"""Generate assets/data/kanji.json from kanjiapi.dev (KANJIDIC2/JMdict, CC BY-SA 4.0)."""
import json, pathlib, sys, time
import requests

API = "https://kanjiapi.dev/v1"
LEVELS = {"jlpt-5": "n5", "jlpt-4": "n4", "jlpt-3": "n3", "jlpt-2": "n2", "jlpt-1": "n1"}
OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "data" / "kanji.json"


def fetch(path):
    r = requests.get(f"{API}/{path}", timeout=30)
    r.raise_for_status()
    return r.json()


def fetch_examples(literal):
    """Fetch up to 3 example words for a kanji literal.

    Returns a list of dicts: {word, reading, meaning}.
    Returns [] on 404 or any network/parse error.
    """
    try:
        words = fetch(f"words/{literal}")
    except Exception as exc:
        print(f"  words/{literal}: skipped ({exc})", file=sys.stderr)
        return []

    examples = []
    for entry in words:
        if len(examples) >= 3:
            break
        variants = entry.get("variants", [])
        meanings = entry.get("meanings", [])
        if not variants or not meanings:
            continue
        first_variant = variants[0]
        written = first_variant.get("written", "")
        pronounced = first_variant.get("pronounced", "")
        glosses = meanings[0].get("glosses", [])
        if not written or not glosses:
            continue
        examples.append({
            "word": written,
            "reading": pronounced,
            "meaning": glosses[0],
        })
    return examples


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
            examples = fetch_examples(lit)
            out.append({
                "literal": d["kanji"],
                "jlpt": level,
                "on_readings": d.get("on_readings", []),
                "kun_readings": d.get("kun_readings", []),
                "meanings": d.get("meanings", []),
                "stroke_count": d.get("stroke_count", 0),
                "examples": examples,
            })
            time.sleep(0.02)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=0))
    with_ex = sum(1 for k in out if k.get("examples"))
    print(f"wrote {len(out)} kanji ({with_ex} with examples) -> {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
