# Dataset Tooling

`generate_kanji_dataset.py` builds `../assets/data/kanji.json` from
[kanjiapi.dev](https://kanjiapi.dev) (KANJIDIC2, CC BY-SA 4.0). It fetches the
JLPT N5–N1 kanji lists, then per-literal detail, dedups, and emits a JSON array
of `{literal, jlpt, on_readings, kun_readings, meanings, stroke_count}`.

## Usage

```bash
cd tool
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
python generate_kanji_dataset.py
```

The script hits the network for ~thousands of kanji and may take several
minutes. The output `kanji.json` is committed; regenerate only when refreshing
the dataset.

See `../assets/data/ATTRIBUTION.md` for data licensing.
