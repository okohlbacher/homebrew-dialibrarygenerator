cask "dialibrarygenerator-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.0.0"
  sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
         intel: "0000000000000000000000000000000000000000000000000000000000000000"

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
  command_wrapper "DIALibraryGenerator",
                  executable: "#{staged_path}/bin/DIALibraryGenerator"

  caveats <<~EOS
    This tool ships no model weights. It needs the three AlphaPeptDeep ONNX
    exports (peptdeep_{rt,ms2,ccs}_dynamic.onnx) in one directory, named by
    DIALIBGEN_MODEL_DIR or in the config. See the project README.
  EOS
end
