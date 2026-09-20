cask "dialibgen-cli" do
  arch arm: "arm64", intel: "x64"

  version "0.10.1"
  sha256 arm:   "0dc1d9a8252b2cea3445c3c7f92ea33645347f0d1ea91074bf5a9e77643b6476",
         intel: "1d5b3c3cfd49480453c6e80003642575f024b6ad29c0c9c804d5d3bd0d3cdecf"

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

  # Homebrew expresses whole macOS releases; the binary needs at least 13.3.
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
