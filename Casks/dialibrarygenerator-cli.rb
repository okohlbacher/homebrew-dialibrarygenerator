cask "dialibrarygenerator-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.9.1"
  sha256 arm:   "67a0874428f203b78774cc4f7746f78311385e9a55c71bb70b389782a8d9dbc6",
         intel: "560ef4202c932e886fc2dec3c50dd051239641c5608873113c37a0365a71e892"

  # A versioned download URL, never releases/latest/download/: a pinned digest
  # has to point at a file that cannot change underneath it.
  url "https://github.com/okohlbacher/DIALibraryGenerator/releases/download/v#{version}/DIALibraryGenerator-macos-#{arch}.tar.gz"
  name "DIALibraryGenerator command-line tool"
  desc "In-silico DIA spectral library generation from a FASTA"
  homepage "https://github.com/okohlbacher/DIALibraryGenerator"

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
  # $(brew --prefix)/bin/DIALibraryGenerator at the staged executable, and the
  # tool then resolves share/DIALibraryGenerator and share/OpenMS relative to
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
  command_wrapper "DIALibraryGenerator",
                  executable: "#{staged_path}/bin/DIALibraryGenerator"
  command_wrapper "dialibgen-fetch-models",
                  executable: "#{staged_path}/bin/dialibgen-fetch-models"

  caveats <<~EOS
    No model weights are shipped. Fetch them once:

        dialibgen-fetch-models

    That downloads the three AlphaPeptDeep ONNX exports, checks each against a
    pinned SHA256, and puts them where this tool already looks -- nothing to
    set afterwards. A cask upgrade replaces this directory, so run it again
    after upgrading.

    The FIRST run takes several minutes and is not stuck. macOS validates each
    of the 145 bundled libraries with Apple individually; the verdict is cached
    and every later run starts in about a second.
  EOS
end
