cask "dialibgen" do
  arch arm: "arm64", intel: "x64"

  version "0.11.4"
  sha256 arm:   "58731cd89075846852e7288215932614cc530d7ffd4259cb646b5ef11bf5e5a5",
         intel: "e3a22ed2493b25faea8c40e764079d2b82d1f2a0480d8540888ab254347de01b"

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
