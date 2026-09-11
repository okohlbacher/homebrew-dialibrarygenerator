# homebrew-dialibrarygenerator

A Homebrew tap for [DIALibraryGenerator](https://github.com/okohlbacher/DIALibraryGenerator):
in-silico DIA spectral library generation from a FASTA, built on OpenMS.

macOS only, and a tap rather than homebrew-core — core does not accept
pre-built binaries for a tool this size, and a from-source formula would mean
building OpenMS on the user's machine.

## These builds are unsigned

The releases this tap points at carry no Apple Developer ID and are not
notarized. On current macOS that has a consequence you should know before
installing: **a binary installed through Homebrew is refused by Gatekeeper the
first time it runs**, with no error message — it is killed, or it stops before
`main` and waits. Removing `com.apple.quarantine` does not change it, and
Homebrew 6 no longer has a `--no-quarantine` flag.

The route that works today is to download the release archive and extract it
yourself:

```bash
curl -fsSLO https://github.com/okohlbacher/DIALibraryGenerator/releases/latest/download/DIALibraryGenerator-macos-arm64.tar.gz
tar xzf DIALibraryGenerator-macos-arm64.tar.gz
./bin/DIALibraryGenerator --help
```

After a blocked run, System Settings → Privacy & Security may also offer an
"Allow Anyway" button. That is the usual path for unsigned software; it needs a
click, so it is not verified here.

Everything else about the casks and the formula is in order, and none of it
needs to change once the releases are signed.

## Installing from the tap

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator       # desktop app
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator-cli   # CLI on PATH
brew install okohlbacher/dialibrarygenerator/dialibrarygenerator              # CLI, as a formula
```

The fully qualified name taps this repository and trusts just that cask, which
Homebrew 6 requires before it will load Ruby from a third-party tap.

Two casks: the app already carries its own private copy of the CLI, so one cask
installing both would put the same tree on disk twice, and the audiences differ
— a workstation versus a server or a script. The formula is an alternative route
to the CLI that keeps its bundled libraries in `libexec` rather than linking
them into the Homebrew prefix, where they would collide with other formulae.

Both require macOS 14. The binaries are built for 13.3 and Homebrew's `macos:`
symbols name whole releases, so the cask rounds up rather than promise a machine
it cannot load on.

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
committing anything. It needs no secrets, which is why it lives here rather than
in the product repository.

Two consequences worth knowing:

- A release is picked up within six hours, not immediately. Run the workflow by
  hand (`workflow_dispatch`, optionally with a `tag`) to publish one now.
- GitHub disables a scheduled workflow after 60 days without a commit, and a run
  that changes nothing commits nothing. If releases stop for two months, the
  schedule stops with them.
