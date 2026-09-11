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

  depends_on macos: :ventura

  livecheck do
    url :url
    strategy :github_latest
  end

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
