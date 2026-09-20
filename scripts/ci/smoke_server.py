#!/usr/bin/env python3
"""Load the datapacks into a real vanilla server, /reload it and look for errors.

    python scripts/ci/smoke_server.py meta  [--mc-version 26.3]   # prints java=<major> (also to $GITHUB_OUTPUT)
    python scripts/ci/smoke_server.py run   [--mc-version 26.3]   # downloads the server, starts it, checks the log

Why: `mecha` only parses syntax. Errors such as `Incorrect argument for command` in a function only show up
when the game itself loads the pack (see README "Validation status"). This starts the real server with the
core pack and the demo pack, reloads, runs a few read-only commands and fails on any load error in the log.

Testing hook: SMOKE_SERVER_CMD='["python3","fake_server.py"]' replaces the java command (no download).
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
WORK = Path(os.environ.get("SMOKE_DIR", ROOT / "smoke-server"))

ERROR_PATTERNS = [re.compile(p) for p in (
    r"Failed to load function", r"Whilst parsing command", r"Couldn't parse", r"Failed to parse", r"Couldn't load",
    r"Failed to load (?:advancement|tag|predicate|recipe|loot)", r"Failed to execute", r"\[Server thread/ERROR\]",
    r"\[ServerMain/ERROR\]", r"Exception",
)]
# (console command, regex the answer must contain, description)
EXPECT = [
    ("datapack list enabled", r"file/guikit\b", "core pack is enabled"),
    ("datapack list enabled", r"file/guikit-demo", "demo pack is enabled"),
    ("scoreboard objectives list", r"guikit\.timer", "load created the objectives"),
    ("data get storage guikit:reg menus", r"demo:main", "#guikit:register filled the menu registry"),
    ("data get storage guikit:reg containers", r"chest_minecart", "container registry is filled"),
]


def fetch_json(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "guikit-ci"}), timeout=60) as r:
        return json.load(r)


def version_meta(mc_version):
    manifest = fetch_json(MANIFEST)
    ent = next((v for v in manifest["versions"] if v["id"] == mc_version), None)
    if ent is None:
        raise SystemExit(f"::error title=smoke::Minecraft version {mc_version} is not in the Mojang manifest")
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


def download_server(mc_version):
    meta = version_meta(mc_version)
    dl = meta["downloads"]["server"]
    jar = WORK / "server.jar"
    print(f"downloading {dl['url']}")
    with urllib.request.urlopen(dl["url"], timeout=300) as r, open(jar, "wb") as fh:
        shutil.copyfileobj(r, fh)
    sha1 = hashlib.sha1(jar.read_bytes()).hexdigest()
    if sha1 != dl["sha1"]:
        raise SystemExit(f"::error title=smoke::server.jar sha1 {sha1} does not match the manifest {dl['sha1']}")
    return jar


def prepare(mc_version):
    if WORK.exists():
        shutil.rmtree(WORK)
    (WORK / "world" / "datapacks").mkdir(parents=True)
    core = WORK / "world" / "datapacks" / "guikit"
    core.mkdir()
    shutil.copy(ROOT / "pack.mcmeta", core / "pack.mcmeta")
    shutil.copytree(ROOT / "data", core / "data")
    demo = ROOT / "examples" / "guikit-demo"
    if demo.is_dir():
        shutil.copytree(demo, WORK / "world" / "datapacks" / "guikit-demo")
    (WORK / "eula.txt").write_text("eula=true\n")
    (WORK / "server.properties").write_text("\n".join([
        "online-mode=false", "server-port=25599", "view-distance=2", "simulation-distance=2", "spawn-protection=0",
        "max-players=1", "motd=guikit smoke test", "sync-chunk-writes=false", "enable-status=false",
        "generate-structures=false", "spawn-monsters=false", "level-name=world",
        "initial-enabled-packs=vanilla,file/guikit,file/guikit-demo", ""]))
    override = os.environ.get("SMOKE_SERVER_CMD")
    if override:
        return json.loads(override)
    jar = download_server(mc_version)
    return ["java", "-Xms256M", "-Xmx1536M", "-jar", str(jar.name), "nogui"]


class Console:
    """A running server: stdout is collected line by line, commands go to stdin."""

    def __init__(self, cmd):
        self.lines = []
        self.proc = subprocess.Popen(cmd, cwd=WORK, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT, text=True, bufsize=1)
        threading.Thread(target=self._read, daemon=True).start()

    def _read(self):
        for line in self.proc.stdout:
            line = line.rstrip("\n")
            self.lines.append(line)
            print(line, flush=True)

    def send(self, command):
        print(f">>> {command}", flush=True)
        self.proc.stdin.write(command + "\n")
        self.proc.stdin.flush()

    def wait_for(self, regex, timeout, start=0):
        rx, end = re.compile(regex), time.time() + timeout
        while time.time() < end:
            for i in range(start, len(self.lines)):
                if rx.search(self.lines[i]):
                    return i
            if self.proc.poll() is not None and start >= len(self.lines):
                break
            time.sleep(0.2)
        for i in range(start, len(self.lines)):  # one last look after the process ended
            if rx.search(self.lines[i]):
                return i
        return None

    def quiet(self, seconds, timeout):
        end, last, n = time.time() + timeout, time.time(), len(self.lines)
        while time.time() < end:
            if len(self.lines) != n:
                n, last = len(self.lines), time.time()
            elif time.time() - last >= seconds:
                return True
            time.sleep(0.2)
        return False


def cmd_run(args):
    cmd = prepare(args.mc_version)
    failures, results = [], []
    con = Console(cmd)
    boot = int(os.environ.get("SMOKE_BOOT_TIMEOUT", "300"))
    if con.wait_for(r"Done \(", boot) is None:
        con.proc.kill()
        print(f"::error title=smoke::the server did not finish starting within {boot}s")
        return finish(con, ["server did not start"], [])

    def expect_all(phase):
        for command, regex, what in EXPECT:
            mark = len(con.lines)
            con.send(command)
            ok = con.wait_for(regex, 20, mark) is not None
            results.append((phase, what, ok))
            if not ok:
                failures.append(f"[{phase}] expected `{regex}` after `{command}` ({what})")

    expect_all("after start")
    con.send("reload")
    con.wait_for(r"Reload", 30, max(0, len(con.lines) - 1))
    con.quiet(6, 120)
    expect_all("after reload")
    con.send("stop")
    try:
        con.proc.wait(timeout=90)
    except subprocess.TimeoutExpired:
        con.proc.kill()
    return finish(con, failures, results)


def finish(con, failures, results):
    bad = []
    for line in con.lines:
        if any(p.search(line) for p in ERROR_PATTERNS):
            bad.append(line.strip())
    for line in bad[:30]:
        print(f"::error title=smoke::{line[:300]}")
    for f in failures:
        print(f"::error title=smoke::{f}")
    out = ["### Server smoke test", "", "| step | result |", "| --- | --- |"]
    out += [f"| {ph}: {what} | {'ok' if ok else '**FAILED**'} |" for ph, what, ok in results]
    out += ["", f"log errors: **{len(bad)}**" + ("" if not bad else "\n\n```\n" + "\n".join(x[:200] for x in bad[:15]) + "\n```")]
    text = "\n".join(out) + "\n"
    print(text)
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write(text)
    (WORK / "smoke.log").write_text("\n".join(con.lines) + "\n", encoding="utf-8")
    return 1 if (bad or failures) else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("action", choices=["meta", "run"])
    ap.add_argument("--mc-version", default=os.environ.get("MC_VERSION", "26.3"))
    args = ap.parse_args()
    return cmd_meta(args) if args.action == "meta" else cmd_run(args)


if __name__ == "__main__":
    sys.exit(main())
