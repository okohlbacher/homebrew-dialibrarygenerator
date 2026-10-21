cask "dialibgen" do
  arch arm: "arm64", intel: "x64"

  version "0.13.1"
  sha256 arm:   "5655481919c80b03b6ddcf5a5f0652dcb569d9c91d83179d37a6e1c8d9f1ac1c",
         intel: "2414775103fe6492bc81a93feaf7353409b80d73fc23671690abc733bf632e11"

  url "https://github.com/okohlbacher/DIALibGen/releases/download/v#{version}/DIALibGen-gui-macos-#{arch}.dmg"
  name "DIALibGen"
  desc "Generate, refine and fine-tune DIA spectral libraries"
  homepage "https://github.com/okohlbacher/DIALibGen"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The desktop app requires macOS 14 or later.
  depends_on macos: :sonoma

  app "DIALibGen.app"

  # By bundle id, so this quits ANY running DIALibGen.app, not only
  # the one this cask installed.
  uninstall quit: "de.openms.dialibrarygenerator"

  zap trash: [
    "~/Library/Application Support/de.openms.dialibrarygenerator",
    "~/Library/Caches/de.openms.dialibrarygenerator",
    "~/Library/Preferences/de.openms.dialibrarygenerator.plist",
    "~/Library/Saved Application State/de.openms.dialibrarygenerator.savedState",
    "~/Library/WebKit/de.openms.dialibrarygenerator",
  ]

  caveats <<~EOS
    The app carries its own copy of the command-line tool. Install
    dialibgen-cli only if you also want it on PATH.

    The three AlphaPeptDeep models and CPU fine-tuning runtime are included.
    Use the model directory picker only when selecting different models.
  EOS
end
