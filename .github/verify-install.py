#!/usr/bin/env python3
"""Smoke-test both normally installed casks, without data-path overrides."""
import json
import os
from pathlib import Path
import platform
import plistlib
import re
import signal
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET

if not __debug__:
    raise SystemExit("install checks require Python assertions; unset PYTHONOPTIMIZE")

version, architecture = sys.argv[1:]
assert platform.machine() == architecture, "runner architecture differs from the cask under test"
prefix = Path(subprocess.check_output(["brew", "--prefix"], text=True).strip())
caskroom = Path(subprocess.check_output(["brew", "--caskroom"], text=True).strip())
staged = caskroom / "dialibgen-cli" / version
wrapper = prefix / "bin/DIALibGen"
app = Path("/Applications/DIALibGen.app")
info = plistlib.loads((app / "Contents/Info.plist").read_bytes())
assert info["CFBundleShortVersionString"] == version, "installed app version mismatch"
assert info["CFBundleIdentifier"] == "de.openms.dialibrarygenerator"
app_binary = app / "Contents/MacOS" / info["CFBundleExecutable"]
embedded = app / "Contents/Resources/resources/dialibgen"
assert os.access(wrapper, os.X_OK), "CLI command wrapper missing"
assert str(staged / "bin/DIALibGen") in wrapper.read_text(), "wrapper does not launch the absolute staged CLI"
# No build environment or locally installed models may satisfy this test.
env = {key: os.environ[key] for key in ("HOME", "TMPDIR", "USER", "LOGNAME") if key in os.environ}
env.update(PATH="/usr/bin:/bin:/usr/sbin:/sbin", OPENMS_DISABLE_UPDATE_CHECK="ON")


def run(arguments, cwd=None, timeout=180):
    result = subprocess.run(list(map(str, arguments)), cwd=cwd, env=env,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    assert result.returncode == 0, f"{arguments}: exit {result.returncode}\n{result.stdout}"
    return result.stdout


def check_binary(binary):
    assert os.access(binary, os.X_OK), f"missing executable: {binary}"
    assert architecture in run(["/usr/bin/lipo", "-archs", binary]).split(), f"wrong architecture: {binary}"
    print(f"Executable: {binary} ({architecture})", flush=True)


with tempfile.TemporaryDirectory(prefix="dialibgen-cask-smoke-") as temp:
    work = Path(temp)
    fasta = work / "proteins.fasta"
    fasta.write_text(">smoke\nPEPTIDEKAAAAAAAAAAR\n")
    for label, root, binary in (("cli", staged, wrapper), ("gui", embedded, embedded / "bin/DIALibGen")):
        check_binary(root / "bin/DIALibGen")
        for head in ("rt", "ms2", "ccs"):
            model = root / "share/DIALibGen/models" / f"peptdeep_{head}_dynamic.onnx"
            assert model.is_file() and model.stat().st_size > 0, f"bundled model missing: {model}"
            print(f"Model: {model} ({model.stat().st_size} bytes)", flush=True)
        assert (root / "share/OpenMS/CHEMISTRY/unimod.xml").is_file(), "bundled OpenMS data missing"
        assert (root / "share/DIALibGen/irt_standards.tsv").is_file(), "bundled iRT standards missing"
        help_text = run([binary, "--help"], work)
        assert re.search(r"\bVersion:\s*" + re.escape(version) + r"(?=\s|$)", help_text), help_text
        ini = work / f"{label}.ini"
        run([binary, "-write_ini", ini], work)
        items = {item.get("name"): item for item in ET.parse(ini).iter("ITEM")}
        assert all(mode in items["mode"].get("restrictions", "") for mode in ("generate", "refine", "tune"))
        assert "tune_out_models" in items, "CPU training options missing"
        for mode in ("generate", "refine", "tune"):
            config = work / f"{label}-{mode}.json"
            run([binary, "-mode", mode, "-write_config", config], work)
            assert isinstance(json.loads(config.read_text()), dict), f"invalid {mode} config"
        library = work / f"{label}.tsv"
        run([binary, "-in", fasta, "-out", library, "-threads", "1"], work)
        assert len(library.read_text().splitlines()) > 1, f"{label}: prediction produced no fragments"
        print(f"PASS: installed {label} CLI {version}, all modes, model-backed generation", flush=True)

check_binary(app_binary)


def app_pids():
    # Compare the full executable path, never a substring matching another app.
    processes = run(["/bin/ps", "-axww", "-o", "pid=,comm="])
    return [int(fields[0]) for line in processes.splitlines()
            if len(fields := line.strip().split(None, 1)) == 2 and fields[1] == str(app_binary)]


assert not app_pids(), "unexpected pre-existing GUI process on the fresh runner"
# LaunchServices applies the normal downloaded-app policy. Never strip quarantine.
launcher = subprocess.Popen(["/usr/bin/open", "-W", "-n", str(app)], env=env)
try:
    deadline = time.monotonic() + 60
    while not app_pids():
        assert launcher.poll() is None, "LaunchServices exited before the GUI started"
        assert time.monotonic() < deadline, "installed GUI did not start within 60 seconds"
        time.sleep(1)
    for _ in range(5):
        time.sleep(1)
        assert app_pids(), "installed GUI exited during the startup check"
    print(f"PASS: {app} launched and remained running", flush=True)
finally:
    for pid in app_pids():
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    try:
        launcher.wait(timeout=10)
    except subprocess.TimeoutExpired:
        launcher.terminate()
        launcher.wait(timeout=10)
