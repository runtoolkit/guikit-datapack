#!/usr/bin/env python3
"""Test the datapacks against the real Minecraft *client* JAR, and report problems as GitHub issues.

    python scripts/ci/mc_test.py meta     [--mc-version 26.3]    # prints java=<major> (also to $GITHUB_OUTPUT)
    python scripts/ci/mc_test.py test     [--mc-version 26.3]    # download client.jar, dump the command tree, validate
    python scripts/ci/mc_test.py security                        # taint scan only (offline, no download)
    python scripts/ci/mc_test.py issues   --findings F.json      # open / update / close issues from a findings file

What "test with the client JAR" means here, and what it does not:
  * client.jar is a GUI application. It cannot be started on a headless runner, and the data pack loader only
    runs once a world is opened. So nothing here launches the client. That is what scripts/ci/smoke_server.py
    already covers (real server, real /reload).
  * What the client JAR does contain is the vanilla data generator (net.minecraft.data.Main). With --reports it
    writes commands.json: the Brigadier command tree of exactly that Minecraft version. Every command in
    every .mcfunction is walked against that tree, which catches "unknown command", "unknown subcommand" and
    "too many / too few arguments" for a version-specific tree, something mecha's bundled grammar can lag behind on.
  * This is a structural check. It does not evaluate argument *values* (selectors, NBT, item components) and it
    does not run any function. `Not verified in a live client` in the README still applies to runtime behaviour.

Security findings are a separate, taint-based scan (see `security()`); a documented macro sink alone is not a finding.

Testing hooks (no network):  MC_TEST_COMMANDS_JSON=<file>  use this commands.json instead of generating one.
                             MC_TEST_DRY_ISSUES=1          print what the issue step would do, call no API.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
WORK = Path(os.environ.get("MC_TEST_DIR", ROOT / "mc-test"))
MARK = "<!-- mc-test:"           # hidden marker: one open issue per fingerprint, never duplicates
LABELS = {"test": "mc-test", "security": "security"}
# The command-tree walk is a re-implementation of Brigadier's parsing rules in ~60 lines and has only been exercised
# against a hand-written miniature tree, never against a real commands.json. Until a run on a real one is confirmed
# clean, its mismatches are WARNINGS (annotations, summary) and do not fail the job or open issues. Set the repository
# variable MC_TEST_STRICT=1 (or the workflow input) to make them errors. Security findings and CI errors are always errors.
STRICT = os.environ.get("MC_TEST_STRICT") == "1"


# --------------------------------------------------------------------------------------- download / meta
def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "guikit-ci"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def version_meta(mc_version):
    ent = next((v for v in fetch_json(MANIFEST)["versions"] if v["id"] == mc_version), None)
    if ent is None:
        raise SystemExit(f"::error title=mc-test::Minecraft version {mc_version} is not in the Mojang manifest")
    return fetch_json(ent["url"])


def cmd_meta(args):
    meta = version_meta(args.mc_version)
    java = str(meta.get("javaVersion", {}).get("majorVersion", 21))
    print(f"minecraft {args.mc_version}: needs Java {java}")
    out = os.environ.get("GITHUB_OUTPUT")
    if out:
        with open(out, "a", encoding="utf-8") as fh:
            fh.write(f"java={java}\n")
    return 0


def _sha1(path):
    h = hashlib.sha1()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _download(url, dest, sha1=None, what=""):
    dest.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "guikit-ci"}), timeout=600) as r, open(dest, "wb") as fh:
        shutil.copyfileobj(r, fh)
    if sha1 and _sha1(dest) != sha1:  # never run or trust a file that does not match the manifest
        raise SystemExit(f"::error title=mc-test::{what or dest.name} sha1 does not match the Mojang manifest")


def _rule_allows(rules):
    """A library `rules` block (os / features) -> True if it applies on a linux runner. No rules = applies."""
    if not rules:
        return True
    allowed = False
    for r in rules:
        osn = (r.get("os") or {}).get("name")
        applies = (osn is None or osn == "linux") and not r.get("features")
        if applies:
            allowed = r.get("action") == "allow"
    return allowed


def download_client(mc_version):
    """Returns (client.jar, [library jars]). The client jar alone is not runnable: since 1.18 the libraries are
    not bundled in it, they are listed in the version json, so the generator needs them on its classpath."""
    meta = version_meta(mc_version)
    dl = meta["downloads"]["client"]
    WORK.mkdir(parents=True, exist_ok=True)
    jar = WORK / "client.jar"
    print(f"downloading {dl['url']} ({dl['size'] // 1024 // 1024} MiB)")
    _download(dl["url"], jar, dl["sha1"], "client.jar")
    libs = []
    for lib in meta.get("libraries", []):
        art = (lib.get("downloads") or {}).get("artifact")
        if not art or not _rule_allows(lib.get("rules")):
            continue
        dest = WORK / "libraries" / art["path"]
        _download(art["url"], dest, art.get("sha1"), lib.get("name", art["path"]))
        libs.append(dest)
    print(f"{len(libs)} libraries downloaded")
    return jar, libs


def generate_commands(jar, libs):
    """Run the vanilla data generator from client.jar; returns the parsed commands.json.

    The client jar's Main-Class is the GUI game, so `java -jar client.jar` would open the game. The generator is a
    separate entry point inside the same jar and is started with -cp. Everything the process prints is kept in
    mc-test/generator.log and its tail is put into the error, so a failure is diagnosable from the job log alone."""
    out = WORK / "generated"
    if out.exists():
        shutil.rmtree(out)
    with zipfile.ZipFile(jar) as z:
        has_main = "net/minecraft/data/Main.class" in z.namelist()
    if not has_main:
        raise SystemExit("::error title=mc-test::client.jar has no net/minecraft/data/Main.class; "
                         "the data generator moved, update generate_commands() in scripts/ci/mc_test.py")
    cp = os.pathsep.join([str(jar)] + [str(x) for x in libs])
    cmd = ["java", "-cp", cp, "net.minecraft.data.Main", "--reports", "--output", str(out)]
    print("+ java -cp <client.jar + %d libraries> net.minecraft.data.Main --reports --output %s" % (len(libs), out), flush=True)
    try:
        res = subprocess.run(cmd, cwd=WORK, capture_output=True, text=True, timeout=600)
    except subprocess.TimeoutExpired:
        raise SystemExit("::error title=mc-test::the data generator did not finish within 600s")
    log = (res.stdout or "") + ("\n--- stderr ---\n" + res.stderr if res.stderr else "")
    (WORK / "generator.log").write_text(log, encoding="utf-8")
    print(log[-3000:])
    if res.returncode != 0:
        tail = " | ".join(x.strip() for x in log.strip().splitlines()[-4:])[:400]
        raise SystemExit(f"::error title=mc-test::the data generator exited with {res.returncode}: {tail}")
    target = out / "reports" / "commands.json"
    if not target.is_file():
        found = sorted(p.relative_to(out).as_posix() for p in out.rglob("*") if p.is_file())[:15]
        raise SystemExit(f"::error title=mc-test::the data generator wrote no {target.relative_to(WORK)}; it wrote: {found or 'nothing'}")
    return json.loads(target.read_text(encoding="utf-8"))


# --------------------------------------------------------------------------------------- command tree walk
def _children(node):
    return node.get("children", {}) or {}


def _lex(rest):
    """Split a command remainder into argument tokens, keeping (), {}, [], quotes together (SNBT, selectors, JSON)."""
    toks, cur, depth, quote, esc = [], [], 0, "", False
    for ch in rest:
        if quote:
            cur.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == quote:
                quote = ""
            continue
        if ch in "\"'":
            quote = ch
            cur.append(ch)
        elif ch in "{[(":
            depth += 1
            cur.append(ch)
        elif ch in "}])":
            depth = max(0, depth - 1)
            cur.append(ch)
        elif ch == " " and depth == 0:
            if cur:
                toks.append("".join(cur))
                cur = []
        else:
            cur.append(ch)
    if cur:
        toks.append("".join(cur))
    return toks


_MACRO = re.compile(r"\$\([A-Za-z0-9_]+\)")


def _try(node, toks, i):
    """True if `toks[i:]` can be consumed by this node's subtree. Argument *values* are not validated."""
    if i >= len(toks):
        return bool(node.get("executable", False))
    kids = _children(node)
    tok = toks[i]
    # literals first (a literal that matches is always tried before falling back to arguments)
    if tok in kids and kids[tok].get("type") == "literal":
        if _follow(kids[tok], toks, i + 1):
            return True
    for name, k in kids.items():
        if k.get("type") != "argument":
            continue
        if _follow(k, toks, i + 1) or _greedy(k, toks, i):
            return True
    return False


def _greedy(k, toks, i):
    """greedy_string / message arguments swallow the rest of the line."""
    parser = (k.get("parser") or "")
    if parser in ("minecraft:message",) or (parser == "brigadier:string" and k.get("properties", {}).get("type") == "greedy"):
        return k.get("executable", False)
    return False


def _follow(node, toks, i):
    # `redirect` is a path from the root. `run` redirects to the root itself, which is the EMPTY path [];
    # so test for the key, never for truthiness (that skipped every `execute ... run <command>` chain).
    if "redirect" in node:
        tgt = _resolve(node["redirect"])
        if tgt is not None:
            # a redirect only forwards the *rest* of the line; with nothing left, the command ends on this node
            # and is valid only if the node itself is executable (`execute as @s` alone is not, `run` alone is not)
            return _try(tgt, toks, i) if i < len(toks) else bool(node.get("executable", False))
    return _try(node, toks, i)


TREE = {}


def _resolve(path):
    node = TREE
    for p in path:
        node = _children(node).get(p)
        if node is None:
            return None
    return node


def command_ok(tree, line):
    """Returns (ok, reason). `line` has no leading slash, macros already replaced by a placeholder."""
    global TREE
    TREE = tree
    toks = _lex(line)
    if not toks:
        return True, ""
    root = _children(tree)
    if toks[0] not in root:
        return False, f"unknown command `{toks[0]}`"
    node = root[toks[0]]
    if len(toks) == 1:
        return (True, "") if node.get("executable") else (False, f"`{toks[0]}` needs arguments")
    return (True, "") if _try(node, toks, 1) else (False, "arguments do not match any syntax of this command in this version")


def iter_command_lines():
    """Yield (relpath, lineno, command-text) for every command in every pack. Macro lines are placeholder-filled."""
    for base in (ROOT, ROOT / "examples" / "guikit-demo"):
        data = base / "data"
        if not data.is_dir():
            continue
        for f in sorted(data.rglob("*.mcfunction")):
            rel = f.relative_to(ROOT).as_posix()
            text = f.read_text(encoding="utf-8", errors="replace").replace("\\\n", "")
            for n, raw in enumerate(text.splitlines(), 1):
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue
                is_macro = line.startswith("$")
                line = line.lstrip("$").lstrip("/")
                if is_macro:
                    line = _MACRO.sub("0", line)       # a numeric placeholder; values are not validated anyway
                yield rel, n, line, is_macro


def validate_commands(tree):
    findings, checked = [], 0
    for rel, n, line, is_macro in iter_command_lines():
        checked += 1
        ok, why = command_ok(tree, line)
        if not ok:
            # a macro line whose placeholder could not fit (e.g. `run $(cmd)`) is reported softer: it is not decidable here
            level = "warning" if (is_macro and re.search(r"run 0$|^0$", line)) or not STRICT else "error"
            findings.append({"kind": "test", "level": level, "file": rel, "line": n, "title": f"command does not match the {tree_version()} command tree",
                             "detail": f"`{line[:160]}` -> {why}"})
    return findings, checked


def tree_version():
    return os.environ.get("MC_VERSION", "target")


# --------------------------------------------------------------------------------------- security (taint) scan
# A macro sink is a place where text from storage becomes *code*: a command, a function id, a JSON string in a
# click event. Sinks are normal in a framework whose README documents them. It becomes a vulnerability when a value
# that a player controls can reach one. So this scan looks for the *flow*, not for the sink.
SINKS = [
    (re.compile(r"^\$.*\brun\s+\$\((\w+)\)\s*$"), "command", "a whole command is taken from a macro variable"),
    (re.compile(r"^\$.*\brun\s+function\s+\$\((\w+)\)"), "function", "a function id is taken from a macro variable"),
    (re.compile(r"^\$.*\bfunction\s+\$\((\w+)\)"), "function", "a function id is taken from a macro variable"),
    (re.compile(r"^\$.*\"action\"\s*:\s*\"(?:run_command|suggest_command)\".*\$\((\w+)\)"), "click", "click_event run/suggest_command takes a macro variable"),
    (re.compile(r"^\$.*\"url\"\s*:\s*\"\$\((\w+)\)\""), "url", "open_url takes a macro variable"),
    (re.compile(r"^\$.*\btellraw\b.*\"text\"\s*:\s*\"\$\((\w+)\)\""), "json", "a macro variable is placed inside a JSON string (quote injection)"),
]
# Data that a player, not the pack author, controls.
TAINT_SOURCES = [
    (re.compile(r"data modify storage (\S+) (\S+) set from entity (@[aeprs]\b\S*|\S+) (\S+)"), "entity data"),
    (re.compile(r"data modify storage (\S+) (\S+) set from block\b"), "block data (signs, books, containers are player-editable)"),
    (re.compile(r"data modify storage (\S+) (\S+) (?:set|append|merge) from (?:entity|block)\b"), "entity/block data"),
    (re.compile(r"execute store result storage (\S+) (\S+) .* run trigger\b"), "trigger value"),
    (re.compile(r"data modify storage (\S+) (\S+) set from storage minecraft:command_storage_[^ ]+"), "foreign storage"),
]
# A sink is fine when the value passes a validation the scan can see (matches a fixed allowlist) before use.
GUARD = re.compile(r"(if data storage \S+ \{[^}]+\})|(if predicate )|(unless data storage \S+ \S+\[\{)|(matches )")
ALLOW_FILE = ROOT / ".github" / "ci" / "security-allow.json"   # {"fingerprints": ["..."]} accepted, reviewed sinks


def fingerprint(kind, file, extra):
    return hashlib.sha256(f"{kind}|{file}|{extra}".encode()).hexdigest()[:12]


def load_allow():
    if ALLOW_FILE.is_file():
        try:
            return set(json.loads(ALLOW_FILE.read_text(encoding="utf-8")).get("fingerprints", []))
        except (ValueError, OSError):
            print(f"::warning title=mc-test::{ALLOW_FILE.relative_to(ROOT)} is not valid JSON, allowlist ignored")
    return set()


def security():
    """Returns findings. Sinks are collected, then each is checked for a player-controlled storage path reaching it."""
    allow = load_allow()
    files = {}
    for base in (ROOT, ROOT / "examples" / "guikit-demo"):
        data = base / "data"
        if data.is_dir():
            for f in sorted(data.rglob("*.mcfunction")):
                files[f.relative_to(ROOT).as_posix()] = f.read_text(encoding="utf-8", errors="replace").splitlines()

    # 1. every place a player-controlled value is written into storage:  {(storage, path): (file, line, why)}
    tainted = {}
    for rel, lines in files.items():
        for n, raw in enumerate(lines, 1):
            for rx, why in TAINT_SOURCES:
                m = rx.search(raw)
                if m:
                    tainted.setdefault((m.group(1), m.group(2).split(".")[0]), (rel, n, why))

    # 2. every sink, and the storage that feeds it (`function X with storage S ...` calls it)
    sinks = []
    for rel, lines in files.items():
        for n, raw in enumerate(lines, 1):
            for rx, kind, why in SINKS:
                m = rx.search(raw.strip())
                if m:
                    sinks.append({"file": rel, "line": n, "kind": kind, "var": m.group(1), "why": why, "text": raw.strip()})

    fid_of = lambda rel: re.sub(r"^(?:examples/[^/]+/)?data/([^/]+)/function/(.+)\.mcfunction$", r"\1:\2", rel)
    callers = {}
    for rel, lines in files.items():
        for n, raw in enumerate(lines, 1):
            m = re.search(r"\bfunction\s+([a-z0-9_.-]+:[a-z0-9_./-]+)\s+with\s+storage\s+(\S+)(?:\s+(\S+))?", raw)
            if m:
                callers.setdefault(m.group(1), []).append((rel, n, m.group(2), (m.group(3) or "").split(".")[0], raw))

    findings = []
    for s in sinks:
        fid = fid_of(s["file"])
        feeders = callers.get(fid, [])
        hit = None
        for (crel, cn, storage, path, raw) in feeders:
            src = tainted.get((storage, path)) or tainted.get((storage, s["var"]))
            if src:
                hit = (crel, cn, storage, path, src)
                break
        fp = fingerprint("taint" if hit else "sink", s["file"], s["var"])
        if fp in allow:
            continue
        if hit:
            crel, cn, storage, path, src = hit
            findings.append({
                "kind": "security", "level": "error", "file": s["file"], "line": s["line"], "fingerprint": fp,
                "title": f"player-controlled data can reach a {s['kind']} sink (`$({s['var']})`)",
                "detail": (f"{s['why']}.\n\nSink: `{s['file']}:{s['line']}` -> `{s['text'][:200]}`\n"
                           f"Called from `{crel}:{cn}` with storage `{storage}`, which is written from **{src[2]}** at `{src[0]}:{src[1]}`.\n\n"
                           "Fix: validate the value against a fixed allowlist before it is macro-expanded, or do not take it from player-editable data.")})
        elif not feeders:
            # a sink nobody in this repo calls is either an API entry point (documented) or dead code; both are informational
            findings.append({"kind": "security-info", "level": "notice", "file": s["file"], "line": s["line"], "fingerprint": fp,
                             "title": f"macro sink `$({s['var']})` has no caller in this repository",
                             "detail": f"{s['why']}. `{s['text'][:200]}`\n\nIt is an entry point for other data packs. If this is documented in the README, "
                                       f"add fingerprint `{fp}` to `.github/ci/security-allow.json`."})
    return findings


# --------------------------------------------------------------------------------------- reporting
def annotate(f):
    lvl = {"error": "error", "warning": "warning", "notice": "notice"}[f["level"]]
    head = f["detail"].splitlines()[0][:300]
    print(f"::{lvl} file={f['file']},line={f['line']},title=mc-test {f['kind']}::{f['title']}: {head}")


def write_summary(findings, checked, extra=""):
    by = lambda k: [f for f in findings if f["kind"] == k]
    out = ["### Minecraft client test", "", extra, "",
           f"| check | result |", "| --- | --- |",
           f"| commands walked against the client command tree | {checked} |",
           f"| command errors | {sum(1 for f in by('test') if f['level'] == 'error')} |",
           f"| command warnings | {sum(1 for f in by('test') if f['level'] == 'warning')} |",
           f"| security findings (taint reaches a sink) | **{len(by('security'))}** |",
           f"| security notes (informational) | {len(by('security-info'))} |", ""]
    for f in [x for x in findings if x["level"] == "error"][:25]:
        out.append(f"- `{f['file']}:{f['line']}` {f['title']}")
    # the full data flow for security findings lives here (a job summary needs repository access), not in the public issue
    for f in [x for x in findings if x["kind"] in ("security", "security-info")][:15]:
        out += ["", f"<details><summary><code>{f['file']}:{f['line']}</code> {f['title']}</summary>", "", f["detail"], "", "</details>"]
    text = "\n".join(out) + "\n"
    print(text)
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write(text)


def cmd_test(args):
    os.environ["MC_VERSION"] = args.mc_version
    WORK.mkdir(parents=True, exist_ok=True)
    findings, checked, note = [], 0, ""
    override = os.environ.get("MC_TEST_COMMANDS_JSON")
    try:
        if override:
            tree = json.loads(Path(override).read_text(encoding="utf-8"))
        else:
            jar, libs = download_client(args.mc_version)
            tree = generate_commands(jar, libs)
        note = f"client `{args.mc_version}` command tree: {len(_children(tree))} top-level commands."
        findings, checked = validate_commands(tree)
    except (SystemExit, Exception) as e:          # download / generator problem: a finding about the CI, not the pack
        msg = str(e) if isinstance(e, SystemExit) else f"::error title=mc-test::{type(e).__name__}: {e}"
        print(msg)
        findings.append({"kind": "ci", "level": "error", "file": ".github/workflows/ci.yml", "line": 1,
                         "title": "mc-test could not obtain the command tree", "detail": re.sub(r"^::error title=mc-test::", "", msg)})
    findings += security()
    for f in findings:
        annotate(f)
    (WORK / "findings.json").write_text(json.dumps(findings, indent=2), encoding="utf-8")
    write_summary(findings, checked, note)
    return 1 if any(f["level"] == "error" for f in findings) else 0


def cmd_security(_args):
    findings = security()
    for f in findings:
        annotate(f)
    WORK.mkdir(parents=True, exist_ok=True)
    (WORK / "findings.json").write_text(json.dumps(findings, indent=2), encoding="utf-8")
    write_summary(findings, 0)
    return 1 if any(f["level"] == "error" for f in findings) else 0


# --------------------------------------------------------------------------------------- issues
def gh(*a, inp=None):
    return subprocess.run(["gh", *a], capture_output=True, text=True, input=inp)


def cmd_issues(args):
    """One issue per problem class. Existing open issues are updated, resolved ones are closed: no duplicates, no spam."""
    findings = json.loads(Path(args.findings).read_text(encoding="utf-8"))
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    run_url = f"{os.environ.get('GITHUB_SERVER_URL', 'https://github.com')}/{repo}/actions/runs/{os.environ.get('GITHUB_RUN_ID', '')}"
    dry = os.environ.get("MC_TEST_DRY_ISSUES") == "1"

    groups = {}
    for f in findings:
        if f["level"] != "error":
            continue
        kind = "security" if f["kind"] == "security" else "test"
        key = f.get("fingerprint") or fingerprint(f["kind"], f["file"], f["title"])
        groups[(kind, key)] = f

    existing = {}
    if not dry:
        for label in LABELS.values():
            res = gh("issue", "list", "--repo", repo, "--label", label, "--state", "open", "--limit", "200", "--json", "number,body")
            if res.returncode != 0:
                print(f"::warning title=mc-test::cannot list issues ({res.stderr.strip()[:200]}); skipping the issue step")
                return 0
            for it in json.loads(res.stdout or "[]"):
                m = re.search(re.escape(MARK) + r"([0-9a-f]{12})", it.get("body") or "")
                if m:
                    existing[m.group(1)] = it["number"]

    for (kind, key), f in sorted(groups.items()):
        if kind == "security":
            # A public issue is a public disclosure. It names the place and the class of problem so the maintainer knows where
            # to look, and nothing else: the data flow, the source and any fix hint stay in the (access-controlled) job summary
            # and the findings artifact of the run. Set MC_TEST_PUBLIC_DETAIL=1 for a private repository.
            title = f"[security] possible macro injection in {f['file']}"
            detail = f["detail"] if os.environ.get("MC_TEST_PUBLIC_DETAIL") == "1" else (
                "The `mc-test` security scan reported a problem class at this location. Details (data flow, source, suggested fix) "
                "are in the job summary and the `mc-test-findings` artifact of the linked run; they are deliberately not repeated "
                "in this public issue.")
            body = (f"{MARK}{key} -->\n**{f['file']}:{f['line']}**\n\n{detail}\n\n---\nFound by the `mc-test` job: {run_url}\n"
                    "\nIf this is exploitable, report it through a private security advisory "
                    "(Security tab -> Report a vulnerability), not in this issue.\n")
        else:
            title = "[mc-test] " + f["title"]
            body = f"{MARK}{key} -->\n**{f['file']}:{f['line']}**\n\n{f['detail']}\n\n---\nFound by the `mc-test` job: {run_url}\n"
        if dry:
            print(f"[dry-run] {'update' if key in existing else 'create'} issue: {title}\n{body}\n")
            continue
        if key in existing:
            gh("issue", "comment", str(existing[key]), "--repo", repo, "--body", f"Still present in {run_url}")
            continue
        for label in {kind: LABELS[kind]}.values():
            gh("label", "create", label, "--repo", repo, "--force",
               "--color", "d73a4a" if kind == "security" else "fbca04", "--description", "opened by the mc-test CI job")
        res = gh("issue", "create", "--repo", repo, "--title", title[:250], "--label", LABELS[kind], "--body-file", "-", inp=body)
        print(res.stdout.strip() or res.stderr.strip())

    if not dry:
        live = {k for (_kd, k) in groups}
        for key, number in existing.items():
            if key not in live:
                gh("issue", "close", str(number), "--repo", repo, "--comment", f"No longer reported by {run_url}.")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("action", choices=["meta", "test", "security", "issues"])
    ap.add_argument("--mc-version", default=os.environ.get("MC_VERSION", "26.3"))
    ap.add_argument("--findings", default=str(WORK / "findings.json"))
    args = ap.parse_args()
    return {"meta": cmd_meta, "test": cmd_test, "security": cmd_security, "issues": cmd_issues}[args.action](args)


if __name__ == "__main__":
    sys.exit(main())
