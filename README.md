# DIALibGen Homebrew tap

Install [DIALibGen](https://github.com/okohlbacher/DIALibGen) on Apple Silicon
or Intel Macs running macOS 14 or later:

```bash
brew install --cask okohlbacher/dialibrarygenerator/dialibgen-cli
brew install --cask okohlbacher/dialibrarygenerator/dialibgen
```

The CLI generates, refines and tunes DIA spectral libraries in one
TOPP-compatible executable. The desktop app provides the generation workflow
and includes its own copy of the CLI. Install the CLI cask when you also need
`DIALibGen` on PATH.

Release packages are Developer ID signed and notarized. They include the
three AlphaPeptDeep prediction models, runtime libraries and CPU training;
no Python environment or model download is needed. Override prediction models
with `DIALIBGEN_MODEL_DIR`. See the product's
[usage guide](https://github.com/okohlbacher/DIALibGen/blob/main/docs/usage.md)
for refinement and tuning examples.

macOS can spend time validating downloaded code on its first launch. Measured
startup results and their limits are recorded in the product's
[validation record](https://github.com/okohlbacher/DIALibGen/blob/main/docs/testing.md#macos-startup).

## Updates

The `update-casks` workflow checks for a complete published release every six
hours, computes both architectures' SHA-256 digests, audits both casks, and
installs, runs and uninstalls both casks on Apple Silicon (macOS 14) and Intel
(macOS 15) before committing the update. Checks cover the installed versions,
command wrapper, bundled models, prediction through both copies of the CLI,
and a bounded normal launch of the desktop app. A release maintainer can
dispatch it immediately with an optional `tag`, such as
`v0.11.0`. Draft and prerelease versions are refused.

GitHub may disable schedules after 60 days without repository activity; the
workflow can also be run manually.
