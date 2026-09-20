#!/usr/bin/env python3
"""Compare the data pack format this repo declares with what the newest Minecraft versions use.

    python scripts/ci/mc_drift.py

Reads the Mojang launcher manifest, looks at the latest release and latest snapshot and reports (as workflow
annotations + a job summary) when one of them uses a data pack format above `max_format` in pack.mcmeta.
Advisory: network problems or an unknown JSON layout only produce notices, the exit code stays 0 unless
DRIFT_FAIL=1 is set and a warning was raised.
"""
import json
import os
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"


def fetch_json(url, timeout=30):
    req = urllib.request.Request(url, headers={"User-Agent": "guikit-ci"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.load(resp)


def major(value):
    """A pack format is an int, or [major, minor] in the newer layout."""
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, (list, tuple)) and value and isinstance(value[0], int):
        return value[0]
    return None


def data_format(version):
    """The data pack (major) format of a version json, or None when the layout is not recognised."""
    for key in ("data_pack_version", "data_pack_format"):
        if key in version and major(version[key]) is not None:
            return major(version[key])
    pv = version.get("pack_version")
    if major(pv) is not None:
        return major(pv)
    if isinstance(pv, dict):
        for key, val in pv.items():
            k = key.lower()
            if "data" in k and "minor" not in k and major(val) is not None:
                return major(val)
    return None


def declared(pack_mcmeta):
    meta = json.loads(Path(pack_mcmeta).read_text(encoding="utf-8")).get("pack", {})
    lo, hi = major(meta.get("min_format")), major(meta.get("max_format"))
    if hi is None:  # legacy single number
        hi = major(meta.get("pack_format"))
        lo = lo if lo is not None else hi
    return lo, hi


def annotate(level, msg):
    print(f"::{level} title=mc-drift::{msg}")


def main(fetch=fetch_json):
    lo, hi = declared(ROOT / "pack.mcmeta")
    rows, warned = [], False
    try:
        manifest = fetch(MANIFEST)
        latest = manifest["latest"]
        by_id = {v["id"]: v for v in manifest["versions"]}
    except Exception as e:  # network, DNS, layout: advisory only
        annotate("notice", f"could not read the Mojang version manifest ({type(e).__name__}: {e}); nothing compared")
        return 0
    tested = os.environ.get("MC_VERSION", "")
    for kind in ("release", "snapshot"):
        vid = latest.get(kind)
        if not vid or vid not in by_id:
            continue
        try:
            fmt = data_format(fetch(by_id[vid]["url"]))
        except Exception as e:
            annotate("notice", f"could not read version json of {vid} ({type(e).__name__}: {e})")
            rows.append((kind, vid, "?", "unreadable"))
            continue
        if fmt is None:
            annotate("notice", f"{kind} {vid}: data pack format not found in its version json (layout changed?)")
            rows.append((kind, vid, "?", "unknown layout"))
        elif hi is not None and fmt > hi:
            annotate("warning", f"latest {kind} {vid} uses data pack format {fmt}, this pack declares max_format {hi}: "
                                "check the changelog, test, then raise max_format")
            rows.append((kind, vid, str(fmt), f"NEWER than max_format {hi}"))
            warned = True
        elif lo is not None and fmt < lo:
            rows.append((kind, vid, str(fmt), f"older than min_format {lo}"))
        else:
            rows.append((kind, vid, str(fmt), "inside the declared range"))
    if tested and latest.get("release") and latest["release"] != tested:
        annotate("notice", f"the smoke test / README target Minecraft {tested}, the latest release is {latest['release']}")
    out = ["### Minecraft version drift", "", f"pack.mcmeta declares data pack format {lo}..{hi}; smoke test version `{tested or 'n/a'}`.", "",
           "| channel | version | data pack format | result |", "| --- | --- | ---: | --- |"]
    out += [f"| {k} | `{v}` | {f} | {r} |" for k, v, f, r in rows]
    text = "\n".join(out) + "\n"
    print(text)
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write(text)
    return 1 if warned and os.environ.get("DRIFT_FAIL") == "1" else 0


if __name__ == "__main__":
    sys.exit(main())
