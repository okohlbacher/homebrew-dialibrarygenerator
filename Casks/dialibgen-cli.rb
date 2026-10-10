cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.11.1"
  sha256 arm:   "593a5cf688f19f39d59d8bf9b5646cfac9a339550b60ba06c331a15c386e529e",
         intel: "2dcd9409d00b434caa601e92f0e5a0b1c7d08c69f4604606dbb44c57cb001852"

  # A versioned download URL, never releases/latest/download/: a pinned digest
  # has to point at a file that cannot change underneath it.
  url "https://github.com/okohlbacher/DIALibGen/releases/download/v#{version}/DIALibGen-macos-#{arch}.tar.gz"
  name "DIALibGen command-line tool"
  desc "Generate, refine and tune DIA spectral libraries"
  homepage "https://github.com/okohlbacher/DIALibGen"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Release casks support macOS 14 or later.
  depends_on macos: :sonoma

  # Launch the absolute staged path so the tool finds its bundled data and libraries.
  command_wrapper "DIALibGen",
                  executable: "#{staged_path}/bin/DIALibGen"

  caveats <<~EOS
    The three AlphaPeptDeep prediction models and CPU training runtime are included.
    DIALIBGEN_MODEL_DIR overrides the bundled prediction models.

    Use -mode generate, -mode refine or -mode tune. See DIALibGen --helphelp
    for native TOPP options and https://github.com/okohlbacher/DIALibGen for examples.
  EOS
end
