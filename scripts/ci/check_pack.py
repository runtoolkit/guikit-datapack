#!/usr/bin/env python3
"""Static checks for the guikit datapack(s), run by .github/workflows/ci.yml.

    python scripts/ci/check_pack.py [--strict] [check ...]      (no check = the default set)

Default checks: json  pitfalls  macros  refs  objectives  unused  mcmeta
Extra checks (only when named): hygiene  docs
Generators: `reference [--out FILE]` writes REFERENCE.md, `pr-summary [--base SHA]` summarises a pull request.
--strict (or CHECK_STRICT=1) turns warnings into failures.
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

    @property
    def warnings(self):
        return sum(r["warning"] for r in self.rows.values())

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


def scan_objectives():
    """({name: (file, line)} of created objectives, [(name, file, line)] of every read/write)."""
    created, used = {}, []
    for f in walk((".mcfunction",)):
        for n, line in code_lines(f):
            for m in OBJ_ADD.finditer(line):
                created.setdefault(m.group(1), (rel(f), n))
            names = []
            for rx in (SCORE_WRITE, SCORE_RESET, SCORE_OP, SCORE_COND):
                for m in rx.finditer(line):
                    names += [g for g in m.groups() if g]
            for m in SCORE_SEL.finditer(line):
                names += [kv.split("=")[0].strip() for kv in m.group(1).split(",") if "=" in kv]
            for name in names:
                if "$(" not in name and name not in ("run", "matches"):
                    used.append((name, rel(f), n))
    return created, used


def check_objectives(rep):
    """Every scoreboard objective that code reads or writes must be created by some `scoreboard objectives add`."""
    rep.touch("objectives")
    created, used = scan_objectives()
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


# ------------------------------------------------------------------ extra checks (not part of the default run)

FORBIDDEN_EXT = {".zip", ".jar", ".exe", ".dll", ".class", ".pyc", ".7z", ".rar", ".tar", ".gz", ".tgz", ".mca"}
FORBIDDEN_DIRS = ("dist/", "build/", "out/")
TEXT_EXT = {".mcfunction", ".json", ".mcmeta", ".md", ".yml", ".yaml", ".py", ".txt", ".gitattributes"}
SECRET_PATTERNS = [
    (re.compile(r"ghp_[A-Za-z0-9]{36}"), "GitHub personal access token"),
    (re.compile(r"github_pat_[A-Za-z0-9_]{50,}"), "GitHub fine-grained token"),
    (re.compile(r"AKIA[0-9A-Z]{16}"), "AWS access key id"),
    (re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"), "private key"),
    (re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}"), "Slack token"),
    (re.compile(r"AIza[0-9A-Za-z_-]{35}"), "Google API key"),
]
BIG = 1024 * 1024
LARGE = 256 * 1024


def tracked_files():
    """Tracked files (git ls-files); outside a git checkout, every file of the tree."""
    try:
        out = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, capture_output=True, check=True).stdout
        return [ROOT / p for p in out.decode("utf-8", "replace").split("\0") if p]
    except (OSError, subprocess.CalledProcessError):
        return list(walk(("",)))


def index_eol():
    """{path: 'crlf'|'lf'|...} as stored in the git index (git ls-files --eol)."""
    try:
        out = subprocess.run(["git", "ls-files", "--eol"], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return {}
    res = {}
    for line in out.splitlines():
        meta, _, path = line.partition("\t")
        parts = meta.split()
        if parts and parts[0].startswith("i/"):
            res[path] = parts[0][2:]
    return res


def check_hygiene(rep):
    """Repository hygiene: stray binaries, huge files, secrets, line endings, whitespace, missing header comments."""
    rep.touch("hygiene")
    eol = index_eol()
    no_header, trailing = [], 0
    for f in tracked_files():
        if not f.is_file():
            continue
        r, ext = rel(f), f.suffix.lower()
        if ext in FORBIDDEN_EXT or r.startswith(FORBIDDEN_DIRS):
            rep.error("hygiene", r, 0, "build artifact / binary file is tracked (release assets belong in Releases, not in git)")
        size = f.stat().st_size
        if size > BIG:
            rep.error("hygiene", r, 0, f"file is {size // 1024} KiB (limit {BIG // 1024} KiB)")
        elif size > LARGE:
            rep.warn("hygiene", r, 0, f"file is {size // 1024} KiB, unusually large for a datapack")
        if ext not in TEXT_EXT and f.name != ".gitattributes":
            continue
        raw = f.read_bytes()
        text = raw.decode("utf-8", "replace")
        for rx, what in SECRET_PATTERNS:
            for m in rx.finditer(text):
                rep.error("hygiene", r, text.count("\n", 0, m.start()) + 1, f"looks like a {what}; remove it and rotate the secret")
        if ext != ".mcfunction":  # mcfunction BOM / CRLF are the `pitfalls` check
            if raw.startswith(b"\xef\xbb\xbf"):
                rep.error("hygiene", r, 1, "UTF-8 BOM at the start of the file")
            if eol.get(r) == "crlf" or (r not in eol and b"\r\n" in raw):
                rep.error("hygiene", r, 1, "CRLF line endings in the repository (use LF; .gitattributes keeps it that way)")
        if raw and not raw.endswith(b"\n"):
            rep.warn("hygiene", r, 0, "file does not end with a newline")
        if ext in (".mcfunction", ".json", ".mcmeta", ".py", ".yml", ".yaml"):
            bad = sum(1 for line in text.splitlines() if line != line.rstrip())
            if bad:
                trailing += 1
                rep.warn("hygiene", r, 0, f"{bad} line(s) with trailing whitespace")
        if ext == ".mcfunction":
            first = next((ln.strip() for ln in text.splitlines() if ln.strip()), "")
            if first and not first.startswith("#"):
                no_header.append(r)
    for r in no_header[:10]:
        rep.warn("hygiene", r, 1, "function file does not start with a comment (repo convention: `# guikit :: name` / `# macro: $(..)`)")
    if len(no_header) > 10:
        rep.warn("hygiene", "data", 0, f"... and {len(no_header) - 10} more function files without a leading comment")


# helpers that live under widget/ but are implementation details of another widget
DOCS_INTERNAL = {"guikit:widget/draw_on_cart"}
DOC_TOKEN = re.compile(r"\b([a-z0-9_.-]+):([a-z0-9_.-]+/[a-z0-9_./-]*)")


def check_docs(rep):
    """README drift: function ids it mentions must exist, and every public widget/api function must be mentioned."""
    rep.touch("docs")
    readme = ROOT / "README.md"
    if not readme.is_file():
        rep.warn("docs", "README.md", 0, "no README.md")
        return
    funcs, tags = function_ids(), tag_ids()
    namespaces = {i.split(":")[0] for i in funcs}
    text = readme.read_text(encoding="utf-8", errors="replace")
    for n, line in enumerate(text.splitlines(), 1):
        seen = set()
        for m in list(FUNC_REF.finditer(line)) + list(DOC_TOKEN.finditer(line)):
            if m.re is FUNC_REF:
                is_tag, name = bool(m.group(1)), m.group(2)
            else:
                is_tag, name = False, f"{m.group(1)}:{m.group(2)}"
                nxt = line[m.end():m.end() + 1]
                if nxt in ("*", "<", "{", "$") or name.endswith(("/", "_", ".")):
                    continue  # a wildcard / placeholder such as `guikit:cond/t_*`
            if name.split(":")[0] not in namespaces:
                continue  # example namespaces (`ns:buy`) and minecraft:
            if (is_tag, name) in seen:
                continue
            seen.add((is_tag, name))
            if name not in (tags if is_tag else funcs):
                rep.error("docs", "README.md", n, f"README mentions `{'#' if is_tag else ''}{name}` but it does not exist (renamed or removed?)")
    for id_, f in sorted(funcs.items()):
        if not id_.startswith(("guikit:api/", "guikit:widget/")) or id_ in DOCS_INTERNAL:
            continue
        short = id_.split("/", 1)[1]
        if not re.search(r"(?<![\w-])" + re.escape(short) + r"(?![\w-])", text):
            rep.warn("docs", rel(f), 0, f"`{id_}` is not mentioned in README.md")


def generate_reference(out):
    """REFERENCE.md: functions with their header comments, objectives, storages, tags, function tags, advancements."""
    funcs, tags = function_ids(), tag_ids()
    created, used = scan_objectives()
    uses = {}
    for name, _, _ in used:
        uses[name] = uses.get(name, 0) + 1
    storages, entity_tags = {}, {}
    macro_ids = set()
    lines = ["# guikit reference", "", "_Generated by `python scripts/ci/check_pack.py reference` from the repository; do not edit._", ""]
    groups = {}
    for id_, f in sorted(funcs.items()):
        header, macro = "", False
        for raw in f.read_text(encoding="utf-8-sig", errors="replace").splitlines():
            if not header and raw.strip().startswith("#"):
                header = raw.strip().lstrip("#").strip()
            if raw.startswith("$"):
                macro = True
            for m in re.finditer(r"\bstorage ([a-z0-9_.-]+:[a-z0-9_./-]+)", raw):
                storages[m.group(1)] = storages.get(m.group(1), 0) + 1
            if not raw.strip().startswith("#"):
                for m in re.finditer(r"\btag \S+ (?:add|remove) ([A-Za-z0-9_.+-]+)", raw):
                    entity_tags[m.group(1)] = entity_tags.get(m.group(1), 0) + 1
                for m in re.finditer(r"\btag=!?([A-Za-z0-9_.+-]+)", raw):
                    entity_tags[m.group(1)] = entity_tags.get(m.group(1), 0) + 1
        if macro:
            macro_ids.add(id_)
        groups.setdefault(id_.rsplit("/", 1)[0] if "/" in id_ else id_.split(":")[0] + ":", []).append((id_, header[:150], macro))
    lines += ["| | count |", "| --- | ---: |",
              f"| functions | {len(funcs)} |", f"| macro functions | {len(macro_ids)} |", f"| function tags | {len(tags)} |",
              f"| scoreboard objectives | {len(created)} |", f"| storages | {len(storages)} |", f"| entity tags | {len(entity_tags)} |", ""]
    lines += ["## Functions", ""]
    for group, items in sorted(groups.items()):
        lines.append(f"### `{group}`")
        lines.append("")
        for id_, header, macro in items:
            lines.append(f"- `{id_}`{' (macro)' if macro else ''}" + (f" - {header}" if header else ""))
        lines.append("")
    lines += ["## Scoreboard objectives", "", "| objective | created in | reads/writes |", "| --- | --- | ---: |"]
    for name in sorted(set(created) | set(uses)):
        where = f"`{created[name][0]}`" if name in created else "**never created**"
        lines.append(f"| `{name}` | {where} | {uses.get(name, 0)} |")
    lines += ["", "## Storages", "", "| storage | uses |", "| --- | ---: |"]
    lines += [f"| `{k}` | {v} |" for k, v in sorted(storages.items())]
    lines += ["", "## Entity tags", "", ", ".join(f"`{k}`" for k in sorted(entity_tags)), "", "## Function tags", ""]
    for id_, f in sorted(tags.items()):
        try:
            vals = ", ".join(f"`{v}`" for v in _tag_values(f))
        except (ValueError, AttributeError):
            vals = "(unreadable)"
        lines.append(f"- `#{id_}`: {vals or '(empty)'}")
    lines += ["", "## Advancements", ""]
    for pack in packs():
        for f in sorted((pack / "data").glob("*/advancement/**/*.json")):
            ns = f.relative_to(pack / "data").parts[0]
            sub = f.relative_to(pack / "data" / ns / "advancement").with_suffix("").as_posix()
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                trig = ", ".join(sorted(c.get("trigger", "?") for c in data.get("criteria", {}).values()))
                reward = data.get("rewards", {}).get("function", "")
            except ValueError:
                trig, reward = "(invalid JSON)", ""
            lines.append(f"- `{ns}:{sub}`: trigger {trig}" + (f", reward function `{reward}`" if reward else ""))
    Path(out).write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"reference: {out} ({len(funcs)} functions, {len(created)} objectives, {len(storages)} storages)")


AREAS = [
    ("core functions", "data/guikit/function/"), ("core tags / advancements / other data", "data/guikit/"),
    ("demo pack", "examples/"), ("CI and scripts", (".github/", "scripts/")), ("docs", ("README.md", "LICENSE")),
]


def pr_summary(base):
    """What a pull request changes, as a job summary: files per area, functions added/removed/renamed."""
    def git(*args):
        return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True)
    res = git("diff", "--name-status", "-M", f"{base}...HEAD")
    if res.returncode != 0:
        print(f"::notice title=pr-summary::cannot diff against {base}: {res.stderr.strip()[:200]}")
        return
    changes = [ln.split("\t") for ln in res.stdout.splitlines() if ln]
    def fid(path):
        m = re.match(r"(?:examples/[^/]+/)?data/([^/]+)/function/(.+)\.mcfunction$", path)
        return f"{m.group(1)}:{m.group(2)}" if m else None
    added, removed, renamed, modified = [], [], [], []
    per_area = {}
    for ch in changes:
        status, paths = ch[0][0], ch[1:]
        path = paths[-1]
        area = next((a for a, pre in AREAS if path.startswith(pre)), "other")
        per_area[area] = per_area.get(area, 0) + 1
        ids = [fid(p) for p in paths]
        if status == "A" and ids[-1]:
            added.append(ids[-1])
        elif status == "D" and ids[0]:
            removed.append(ids[0])
        elif status == "R" and ids[0] and ids[-1]:
            renamed.append(f"{ids[0]} -> {ids[-1]}")
        elif status == "M" and ids[-1]:
            modified.append(ids[-1])
    out = ["### Pull request summary", "", f"{len(changes)} file(s) changed against `{base}`.", "",
           "| area | files |", "| --- | ---: |"] + [f"| {a} | {n} |" for a, n in sorted(per_area.items())]
    for title, items in (("Functions added", added), ("Functions removed", removed), ("Functions renamed", renamed),
                         ("Functions modified", modified)):
        if items:
            out += ["", f"**{title} ({len(items)})**", ""] + [f"- `{i}`" for i in sorted(items)[:40]]
            if len(items) > 40:
                out.append(f"- ... and {len(items) - 40} more")
    core_changed = any(p.startswith("data/guikit/") for c in changes for p in c[1:])
    readme_changed = any("README.md" in c[1:] for c in changes)
    if core_changed and not readme_changed:
        out += ["", "> core code changed but README.md did not; if this is user-visible, document it."]
        print("::notice title=pr-summary::core code changed but README.md did not")
    text = "\n".join(out) + "\n"
    print(text)
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write(text)


CHECKS = {
    "json": check_json, "pitfalls": check_pitfalls, "macros": check_macros, "refs": check_refs,
    "objectives": check_objectives, "unused": check_unused, "mcmeta": check_mcmeta,
    "hygiene": check_hygiene, "docs": check_docs,
}
DEFAULT = ["json", "pitfalls", "macros", "refs", "objectives", "unused", "mcmeta"]  # what a bare run does


def main(argv):
    strict = os.environ.get("CHECK_STRICT") == "1"
    args = []
    it = iter(argv)
    out, base = "REFERENCE.md", os.environ.get("BASE_SHA", "")
    for a in it:
        if a == "--strict":
            strict = True
        elif a == "--out":
            out = next(it, out)
        elif a == "--base":
            base = next(it, base)
        else:
            args.append(a)
    if args[:1] == ["reference"]:
        generate_reference(out)
        return 0
    if args[:1] == ["pr-summary"]:
        if not base:
            print("::notice title=pr-summary::no base (set BASE_SHA or pass --base), nothing to summarise")
            return 0
        pr_summary(base)
        return 0
    wanted = args or DEFAULT
    bad = [c for c in wanted if c not in CHECKS]
    if bad:
        print(f"unknown check(s): {', '.join(bad)}; available: {', '.join(CHECKS)}, reference, pr-summary", file=sys.stderr)
        return 2
    rep = Report()
    for name in wanted:
        CHECKS[name](rep)
    rep.summary()
    if strict and rep.warnings:
        print(f"strict mode: {rep.warnings} warning(s) count as failures")
    return 1 if rep.errors or (strict and rep.warnings) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
