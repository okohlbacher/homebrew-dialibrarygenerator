cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.11.4"
  sha256 arm:   "7871aa2009ee6daaf14e316013eda73321c365ee34e57e5abbbcc69117bfa70c",
         intel: "3d44d4070d8f5fd6f86a61eb679f3e709c63da88ad19b8c3cc46073ac013145a"

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
