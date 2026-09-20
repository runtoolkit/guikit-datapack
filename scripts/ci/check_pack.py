#!/usr/bin/env python3
"""Static checks for the guikit datapack(s), run by .github/workflows/ci.yml.

    python scripts/ci/check_pack.py [check ...]          (no argument = all checks)

Checks: json  pitfalls  macros  refs  objectives  unused  mcmeta
Errors fail the run (exit 1), warnings only annotate. Output uses GitHub workflow commands (::error file=..)
so findings show up inline on the changed files; a table is appended to $GITHUB_STEP_SUMMARY when set.
Stdlib only; the `macros` check also needs the `mecha` module (pip install mecha).

Why these checks exist: `mecha .` alone accepted things that the real 26.3 client rejected (see README
"Validation status"), and it does not look at macro lines, function references or scoreboards at all.
"""
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", "node_modules", "__pycache__"}

# ------------------------------------------------------------------ helpers


def rel(p):
    return Path(p).resolve().relative_to(ROOT).as_posix()


def walk(suffixes):
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for f in filenames:
            if f.endswith(tuple(suffixes)):
                yield Path(dirpath) / f


def packs():
    """Every directory with a pack.mcmeta: the root pack and the example packs."""
    return sorted(p.parent for p in walk(("pack.mcmeta",)))


def code_lines(path):
    """(lineno, text) of the non-comment, non-empty lines of an .mcfunction file."""
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    for n, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if s and not s.startswith("#"):
            yield n, s


class Report:
    def __init__(self):
        self.rows = {}

    def _row(self, check):
        return self.rows.setdefault(check, {"error": 0, "warning": 0})

    def emit(self, level, check, file, line, msg):
        self._row(check)[level] += 1
        msg = msg.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
        loc = f"file={file}" + (f",line={line}" if line else "")
        print(f"::{level} {loc},title={check}::{msg}")

    def error(self, check, file, line, msg):
        self.emit("error", check, file, line, msg)

    def warn(self, check, file, line, msg):
        self.emit("warning", check, file, line, msg)

    def touch(self, check):
        self._row(check)

    @property
    def errors(self):
        return sum(r["error"] for r in self.rows.values())

    def summary(self):
        out = ["### guikit static checks", "", "| check | errors | warnings |", "| --- | ---: | ---: |"]
        for c, r in self.rows.items():
            out.append(f"| `{c}` | {r['error']} | {r['warning']} |")
        text = "\n".join(out) + "\n"
        print("\n" + text)
        target = os.environ.get("GITHUB_STEP_SUMMARY")
        if target:
            with open(target, "a", encoding="utf-8") as fh:
                fh.write(text)


def function_ids():
    """{'ns:path': Path} for every function in every pack."""
    ids = {}
    for pack in packs():
        for f in (pack / "data").glob("*/function/**/*.mcfunction"):
            ns = f.relative_to(pack / "data").parts[0]
            sub = f.relative_to(pack / "data" / ns / "function").with_suffix("").as_posix()
            ids[f"{ns}:{sub}"] = f
    return ids


def tag_ids():
    ids = {}
    for pack in packs():
        for f in (pack / "data").glob("*/tags/function/**/*.json"):
            ns = f.relative_to(pack / "data").parts[0]
            sub = f.relative_to(pack / "data" / ns / "tags" / "function").with_suffix("").as_posix()
            ids[f"{ns}:{sub}"] = f
    return ids


# ------------------------------------------------------------------ checks


def check_json(rep):
    """Every .json and pack.mcmeta must parse (advancements, tags, pack.mcmeta)."""
    rep.touch("json")
    for f in list(walk((".json",))) + list(walk(("pack.mcmeta",))):
        try:
            json.loads(f.read_text(encoding="utf-8"))
        except (ValueError, UnicodeDecodeError) as e:
            rep.error("json", rel(f), getattr(e, "lineno", 0), f"invalid JSON: {e}")


P_PATH_SPACE = re.compile(r"\bdata storage \S+ [^\s{}]+ +\{")
P_JSON_STRING = re.compile(r"(?:custom_name|CustomName)\s*[=:]\s*'")
P_OLD_NAME = re.compile(r"\b(?:name|lore|title):'[\[{]")
P_ROOT_SET = re.compile(r"\bdata modify storage \S+ \{\} ")
BAD_PATH = re.compile(r"[^a-z0-9_./-]")


def check_pitfalls(rep):
    """Things the real 26.3 client rejected or silently ignored, that mecha accepts (see README)."""
    rep.touch("pitfalls")
    for f in walk((".mcfunction",)):
        raw = f.read_bytes()
        if raw.startswith(b"\xef\xbb\xbf"):
            rep.error("pitfalls", rel(f), 1, "UTF-8 BOM at the start of a function file (breaks the first line)")
        if b"\r\n" in raw:
            rep.error("pitfalls", rel(f), 1, "CRLF line endings in a function file (use LF)")
        old_names = 0
        for n, line in code_lines(f):
            if P_PATH_SPACE.search(line):
                rep.error("pitfalls", rel(f), n, "NBT path followed by a space and a compound filter; the compound must be "
                          "attached to the path (`cur{close:1b}`, not `cur {close:1b}`): 26.3 rejects this at load")
            if P_JSON_STRING.search(line):
                rep.error("pitfalls", rel(f), n, "custom_name / CustomName given as a quoted JSON string; in 26.3 that is a plain "
                          "string and shows the JSON text. Use an SNBT text component: {text:\"..\"}")
            if P_ROOT_SET.search(line):
                rep.error("pitfalls", rel(f), n, "`data modify storage X {} ...` on the root path did not write in 26.3; "
                          "use `data merge storage X {...}` or copy key by key")
            if P_OLD_NAME.search(line):
                old_names += 1
        if old_names:
            rep.warn("pitfalls", rel(f), 0, f"{old_names} widget name/lore value(s) still written as quoted JSON strings "
                     "(works only through macro expansion); SNBT text components are the documented form")
    # conflict markers anywhere
    for f in walk((".mcfunction", ".json", ".mcmeta", ".yml", ".py", ".md")):
        for n, line in enumerate(f.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            if line.startswith("<<<<<<< ") or line.startswith(">>>>>>> ") or (line == "=======" and f.suffix != ".md"):
                rep.error("pitfalls", rel(f), n, "unresolved merge conflict marker")
    # resource locations must be lowercase [a-z0-9_./-]
    for pack in packs():
        for f in (pack / "data").rglob("*"):
            if f.is_file() and BAD_PATH.search(f.relative_to(pack / "data").as_posix()):
                rep.error("pitfalls", rel(f), 0, "file path is not a valid resource location (only a-z 0-9 _ . / - allowed)")


MACRO_SAMPLES = {
    "slot": "10", "i": "4", "item": "minecraft:diamond", "id": "demo:x", "type": "button",
    "name": '{text:"x",italic:0b}', "lore": "[]", "pad": "minecraft:gray_stained_glass_pane", "obj": "coins",
    "amount": "5", "count": "3", "min": "1", "max": "100", "tag": "vip", "mode": "survival",
    "adv": "minecraft:story/root", "pred": "demo:p", "cmd": "say hi", "url": "https://example.com",
    "timer": "600", "fn": "demo:click/x", "menu": "demo:main", "alias": "demo_main", "ctype": "chest_minecart",
    "entity": "chest_minecart", "title": '{text:"T"}', "uid": "7", "msg": "hi", "color": "red",
    "sound": "minecraft:ui.button.click", "volume": "1.0", "pitch": "1.0", "ticks": "20", "page": "1",
    "width": "5", "full": "minecraft:lime_dye", "empty": "minecraft:gray_dye", "value": "3", "cell": "2", "last": "4",
    "c": "2", "delta": "1", "n": "3",
}


def check_macros(rep):
    """mecha does not validate `$` macro lines. Expand each with sample values and lint the result."""
    rep.touch("macros")
    if importlib.util.find_spec("mecha") is None:
        rep.warn("macros", "scripts/ci/check_pack.py", 0, "the mecha module is not installed, macro expansion lint skipped")
        return
    origin, unknown, n = {}, set(), 0
    with tempfile.TemporaryDirectory() as tmp:
        out_dir = Path(tmp) / "data" / "t" / "function"
        out_dir.mkdir(parents=True)
        shutil.copy(ROOT / "pack.mcmeta", Path(tmp) / "pack.mcmeta")
        for f in walk((".mcfunction",)):
            for ln, line in enumerate(f.read_text(encoding="utf-8-sig", errors="replace").splitlines(), 1):
                if not line.startswith("$"):
                    continue
                text = line[1:]
                for var in set(re.findall(r"\$\((\w+)\)", line)):
                    if var not in MACRO_SAMPLES:
                        unknown.add(var)
                    text = text.replace(f"$({var})", MACRO_SAMPLES.get(var, "1"))
                n += 1
                origin[n] = (rel(f), ln)
                (out_dir / f"l{n}.mcfunction").write_text(text + "\n", encoding="utf-8")
        res = subprocess.run([sys.executable, "-m", "mecha", "."], cwd=tmp, capture_output=True, text=True)
        text = res.stdout + res.stderr
    print(f"macros: {n} macro line(s) expanded")
    if unknown:
        rep.warn("macros", "scripts/ci/check_pack.py", 0,
                 "no sample value for macro variable(s): " + ", ".join(sorted(unknown)) + " (add them to MACRO_SAMPLES)")
    found = False
    for m in re.finditer(r"ERROR\s+\|\s+mecha\s+(.+?)\n\s+\|\s+\S*?l(\d+)\.mcfunction:(\d+):(\d+)", text):
        found = True
        file, ln = origin.get(int(m.group(2)), ("?", 0))
        rep.error("macros", file, ln, f"macro line does not parse after expansion: {m.group(1)}")
    if res.returncode != 0 and not found:
        rep.error("macros", "scripts/ci/check_pack.py", 0, "mecha failed on the expanded macro lines:\n" + text[-1500:])


FUNC_REF = re.compile(r"(?<![\w.:/-])function\s+(#?)([a-z0-9_.-]+:[a-z0-9_./-]+)(?![\w./$-])")
TOKEN = re.compile(r"[a-z0-9_.-]+:[a-z0-9_./-]+")


def _tag_values(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    for v in data.get("values", []):
        yield v["id"] if isinstance(v, dict) else v


def check_refs(rep):
    """Every `function ns:path`, `function #ns:tag`, tag value and advancement reward must exist."""
    rep.touch("refs")
    funcs, tags = function_ids(), tag_ids()

    def known(is_tag, name):
        return name in (tags if is_tag else funcs)

    for id_, f in funcs.items():
        for n, line in code_lines(f):
            for m in FUNC_REF.finditer(line):
                is_tag, name = bool(m.group(1)), m.group(2)
                if name.startswith("minecraft:"):
                    continue
                if not known(is_tag, name):
                    rep.error("refs", rel(f), n, f"`function {'#' if is_tag else ''}{name}` does not exist in any pack of this repo")
    for id_, f in tags.items():
        try:
            values = list(_tag_values(f))
        except (ValueError, AttributeError):
            continue  # reported by the json check
        for v in values:
            is_tag, name = v.startswith("#"), v.lstrip("#")
            if name.startswith("minecraft:"):
                continue
            if not known(is_tag, name):
                rep.error("refs", rel(f), 0, f"tag value `{v}` does not exist")
    for pack in packs():
        for f in (pack / "data").glob("*/advancement/**/*.json"):
            try:
                reward = json.loads(f.read_text(encoding="utf-8")).get("rewards", {}).get("function")
            except ValueError:
                continue
            if reward and not reward.startswith("minecraft:") and reward not in funcs:
                rep.error("refs", rel(f), 0, f"reward function `{reward}` does not exist")


SCORE_WRITE = re.compile(r"scoreboard players (?:set|add|remove|get|enable) \S+ (\S+)")
SCORE_RESET = re.compile(r"scoreboard players reset \S+(?: (\S+))?\s*$")
SCORE_OP = re.compile(r"scoreboard players operation \S+ (\S+) \S+ \S+ (\S+)")
SCORE_COND = re.compile(r"(?:if|unless|store (?:result|success)) score \S+ (\S+)(?: (?:=|<|>|<=|>=) \S+ (\S+))?")
SCORE_SEL = re.compile(r"scores=\{([^}]*)\}")
OBJ_ADD = re.compile(r"scoreboard objectives add (\S+)")


def check_objectives(rep):
    """Every scoreboard objective that code reads or writes must be created by some `scoreboard objectives add`."""
    rep.touch("objectives")
    created, used = set(), []
    for f in walk((".mcfunction",)):
        for n, line in code_lines(f):
            for m in OBJ_ADD.finditer(line):
                created.add(m.group(1))
            names = []
            for rx in (SCORE_WRITE, SCORE_RESET, SCORE_OP, SCORE_COND):
                for m in rx.finditer(line):
                    names += [g for g in m.groups() if g]
            for m in SCORE_SEL.finditer(line):
                names += [kv.split("=")[0].strip() for kv in m.group(1).split(",") if "=" in kv]
            for name in names:
                if "$(" not in name and name not in ("run", "matches"):
                    used.append((name, rel(f), n))
    for name, file, n in used:
        if name not in created:
            rep.error("objectives", file, n, f"scoreboard objective `{name}` is used but never created with `scoreboard objectives add`")


# public API (documented in the README) and entry points that are run by hand: never reported as unused
PUBLIC = ("guikit:api/", "guikit:widget/", "guikit:cond/check", "guikit:internal/cooldown/notify",
          "guikit:internal/selftest", "demo:open")


def check_unused(rep):
    """Functions nothing refers to (warning only): dead code such as replaced helpers."""
    rep.touch("unused")
    funcs = function_ids()
    referenced = set()
    files = [(i, f) for i, f in funcs.items()] + [(None, f) for f in walk((".json",)) if "data" in f.parts]
    for own, f in files:
        text = "\n".join(line for _, line in code_lines(f)) if f.suffix == ".mcfunction" else f.read_text(encoding="utf-8", errors="replace")
        for t in TOKEN.findall(text):
            if t != own:
                referenced.add(t)
    for id_, f in sorted(funcs.items()):
        if id_ not in referenced and not id_.startswith(PUBLIC):
            rep.warn("unused", rel(f), 0, f"`{id_}` is never referenced (not called, not in a tag, not a public API prefix)")


def check_mcmeta(rep):
    """pack.mcmeta sanity, and the same format range across the root pack and the example packs."""
    rep.touch("mcmeta")
    ranges = {}
    for pack in packs():
        f = pack / "pack.mcmeta"
        try:
            meta = json.loads(f.read_text(encoding="utf-8")).get("pack", {})
        except ValueError:
            continue
        if not meta.get("description"):
            rep.error("mcmeta", rel(f), 0, "pack.description is missing or empty")
        lo, hi = meta.get("min_format"), meta.get("max_format")
        if not (isinstance(lo, int) and isinstance(hi, int)):
            rep.error("mcmeta", rel(f), 0, "min_format / max_format must be integers")
            continue
        if lo > hi:
            rep.error("mcmeta", rel(f), 0, f"min_format {lo} is greater than max_format {hi}")
        ranges[rel(f)] = (lo, hi)
    if len(set(ranges.values())) > 1:
        rep.warn("mcmeta", "pack.mcmeta", 0, "packs declare different format ranges: " + ", ".join(f"{k}={v}" for k, v in ranges.items()))


CHECKS = {
    "json": check_json, "pitfalls": check_pitfalls, "macros": check_macros, "refs": check_refs,
    "objectives": check_objectives, "unused": check_unused, "mcmeta": check_mcmeta,
}


def main(argv):
    wanted = argv or list(CHECKS)
    bad = [c for c in wanted if c not in CHECKS]
    if bad:
        print(f"unknown check(s): {', '.join(bad)}; available: {', '.join(CHECKS)}", file=sys.stderr)
        return 2
    rep = Report()
    for name in wanted:
        CHECKS[name](rep)
    rep.summary()
    return 1 if rep.errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
