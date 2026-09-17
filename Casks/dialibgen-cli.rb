cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.10.1"
  sha256 arm:   "0dc1d9a8252b2cea3445c3c7f92ea33645347f0d1ea91074bf5a9e77643b6476",
         intel: "1d5b3c3cfd49480453c6e80003642575f024b6ad29c0c9c804d5d3bd0d3cdecf"

  # A versioned download URL, never releases/latest/download/: a pinned digest
  # has to point at a file that cannot change underneath it.
  url "https://github.com/okohlbacher/DIALibGen/releases/download/v#{version}/DIALibGen-macos-#{arch}.tar.gz"
  name "DIALibGen command-line tool"
  desc "In-silico DIA spectral library generation from a FASTA"
  homepage "https://github.com/okohlbacher/DIALibGen"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The binaries are built with a 13.3 deployment target (libc++ shipped the
  # floating-point std::to_chars there). Homebrew's macos symbols name whole
  # releases, so :ventura would admit 13.0-13.2, where dyld refuses to load
  # them -- the cask would install and the tool would never start. Rounded UP
  # to the next release it can promise. 13.3-13.7 users can still unpack the
  # release tarball directly.
  depends_on macos: :sonoma

  # command_wrapper, NOT `binary`. A plain binary stanza symlinks
  # $(brew --prefix)/bin/DIALibGen at the staged executable, and the
  # tool then resolves share/DIALibGen and share/OpenMS relative to
  # the path it was launched by -- which becomes /opt/homebrew/bin, where
  # neither exists. command_wrapper writes a shim that execs the ABSOLUTE
  # staged path instead, so the relative lookup lands inside the Caskroom
  # where the data and the dylib closure actually are.
  #
  # The second wrapper is the model fetcher: the models are not shipped, so the
  # thing that downloads them has to be on PATH too, and it derives the install
  # prefix from the binary it finds -- which has to resolve into the Caskroom
  # for the same reason. No blank line between the two: brew style requires
  # stanzas of the same kind to be adjacent (Cask/StanzaGrouping).
  command_wrapper "DIALibGen",
                  executable: "#{staged_path}/bin/DIALibGen"
  command_wrapper "dialibgen-fetch-models",
                  executable: "#{staged_path}/bin/dialibgen-fetch-models"

  caveats <<~EOS
    The three AlphaPeptDeep models are included from 0.10.1, so this predicts
    straight away with nothing to set and nothing to download.

    `dialibgen-fetch-models` is still here to refresh or verify them
    (`--check`), and DIALIBGEN_MODEL_DIR still overrides them.

    The FIRST run takes several minutes and is not stuck. macOS validates each
    of the 145 bundled libraries with Apple individually; the verdict is cached
    and every later run starts in about a second.
  EOS
end
