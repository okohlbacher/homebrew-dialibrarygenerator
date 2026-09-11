# homebrew-dialibrarygenerator

A Homebrew tap for [DIALibraryGenerator](https://github.com/okohlbacher/DIALibraryGenerator):
in-silico DIA spectral library generation from a FASTA, built on OpenMS.

## Read this first: these builds are unsigned

The releases this tap points at are **not signed with an Apple Developer ID and
not notarized**. That is a deliberate choice for now, not an oversight — but on
current macOS it has a consequence worth stating plainly, because it is silent:

- A **cask** install completes, and the binary is then killed by Gatekeeper the
  first time it runs (`Killed: 9`), or stops inside `dyld` before `main` at 0%
  CPU and waits. `syspolicyd` logs
  `Adding Gatekeeper denial breadcrumb ... (team: (null))`.
- Removing `com.apple.quarantine` afterwards **does not help**: the decision
  comes from the provenance record, not the attribute.
- Homebrew 6 **removed the `--no-quarantine` flag**, so there is no opt-out at
  install time.
- The **formula** behaves the same way, for the same reason.

Measured on macOS 26.5, not assumed.

**The route that works today** is to download the release archive and extract it
yourself — nothing marks it, and it runs:

```bash
curl -fsSLO https://github.com/okohlbacher/DIALibraryGenerator/releases/latest/download/DIALibraryGenerator-macos-arm64.tar.gz
tar xzf DIALibraryGenerator-macos-arm64.tar.gz
./bin/DIALibraryGenerator --help
```

After a blocked run, System Settings → Privacy & Security may also offer an
"Allow Anyway" button for the binary. That is the standard path for unsigned
software; it needs a click, so it was not verified here.

The casks and the formula are correct in every other respect — pinned version,
per-architecture digests, the right macOS floor, a wrapper that lets the tool
find its own data and libraries — and they need no change the day the releases
are signed.

## Installing from the tap

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator       # desktop app
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator-cli   # CLI on PATH
brew install okohlbacher/dialibrarygenerator/dialibrarygenerator              # CLI, as a formula
```

Two casks: the app already carries its own private copy of the CLI, so one cask
installing both would put the same tree on disk twice, and the audiences differ
(a workstation versus a server or a script). The formula is an alternative route
to the CLI that keeps its 147 bundled libraries in `libexec` rather than linking
them into the Homebrew prefix, where they would collide with every other formula
shipping an Arrow or a Qt.

Both require macOS 14. The binaries are built for 13.3 — libc++ shipped the
floating-point `std::to_chars` there — and Homebrew's `macos:` symbols name
whole releases, so the cask rounds up rather than promise a machine it cannot
load on.

## Models are not included

No model weights are shipped, and no tagged OpenMS release contains them. The
tool needs three AlphaPeptDeep ONNX exports —
`peptdeep_{rt,ms2,ccs}_dynamic.onnx` — in one directory, named by
`DIALIBGEN_MODEL_DIR` or in the config file. The app asks for the directory; the
CLI names the file it could not find and lists where it looked.

## How this stays current

`.github/workflows/update-casks.yml` runs every six hours, resolves the latest
release, computes both architectures' digests from the release assets, rewrites
the version and `sha256` stanzas, then audits, installs and runs the tool before
committing anything.

It computes the digests itself rather than calling `brew bump-cask-pr --version`:
that tool is supposed to resolve the URL once per architecture, and on an arm64
runner it fetched the arm64 asset twice and wrote its digest for both — which
would have shipped an intel cask that refuses its own download.

It needs no secrets, which is why it lives here rather than in the product
repository. Two consequences:

- A release is picked up within six hours, not immediately. Run the workflow by
  hand (`workflow_dispatch`, optionally with a `tag`) to publish one now.
- GitHub disables a scheduled workflow after 60 days without a commit, and a run
  that changes nothing commits nothing. If releases stop for two months, the
  schedule stops with them.
