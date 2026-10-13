cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.11.3"
  sha256 arm:   "c0f93ee71dc4232fa1c40061d06e8a932ae0f570d1d1bcfae85334f954988b8e",
         intel: "6b00436009de17009482e6156f7a8ac34c9ff36e59291c85ae0118db26a845c7"

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
