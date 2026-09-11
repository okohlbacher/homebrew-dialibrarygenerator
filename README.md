# homebrew-dialibrarygenerator

A Homebrew tap for [DIALibraryGenerator](https://github.com/okohlbacher/DIALibraryGenerator):
in-silico DIA spectral library generation from a FASTA, built on OpenMS.

macOS only, and a tap rather than homebrew-core — core does not accept
pre-built binaries for a tool this size, and a from-source formula would mean
building OpenMS on the user's machine.

## Install

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator
```

That is the desktop app. For the command-line tool on `PATH`:

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator-cli
```

Both in one line:

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibrarygenerator okohlbacher/dialibrarygenerator/dialibrarygenerator-cli
```

The fully qualified name taps this repository and trusts just that cask, which
Homebrew 6 requires before it will load Ruby from a third-party tap.

## Why two casks

The app already carries its own private copy of the CLI, so one cask installing
both would put the same tree on disk twice. The audiences differ too — a
workstation versus a server or a script — and each can be upgraded, pinned or
removed on its own.

## Models are not included

Neither cask ships model weights, and no tagged OpenMS release contains them.
The tool needs three AlphaPeptDeep ONNX exports —
`peptdeep_{rt,ms2,ccs}_dynamic.onnx` — in one directory, named by
`DIALIBGEN_MODEL_DIR` or in the config file. The app asks for the directory;
the CLI names the file it could not find and lists where it looked. See the
project README.

## Neither is signed

The disk image is not notarized and the binaries carry no Developer ID, so
macOS will refuse them on first run until you allow them in System Settings →
Privacy & Security. `brew install --cask --no-quarantine` skips that.

## How this stays current

`.github/workflows/update-casks.yml` runs every six hours, resolves the latest
release, and bumps both casks with `brew bump-cask-pr --write-only` — Homebrew's
own tool computes the digests. It then audits, installs, runs the tool from an
unrelated directory and uninstalls before committing anything.

It needs no secrets, which is why it lives here rather than in the product
repository. Two consequences worth knowing:

- A release is picked up within six hours, not immediately. Run the workflow by
  hand (`workflow_dispatch`, optionally with a `tag`) to publish one now.
- GitHub disables a scheduled workflow after 60 days without a commit to the
  repository, and a run that changes nothing commits nothing. If releases stop
  for two months, the schedule stops too and has to be re-enabled.
