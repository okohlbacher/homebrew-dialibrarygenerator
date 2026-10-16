cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.12.1"
  sha256 arm:   "684fe3e8ce3bed2329c3955d98dd478d509b6302fd96c11c086c2e985f97976b",
         intel: "54bd1ee0a8ba018d229c21a897e0cc5c8de2a18f9b9e2b7d22d3e9957f2ea5d1"

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
