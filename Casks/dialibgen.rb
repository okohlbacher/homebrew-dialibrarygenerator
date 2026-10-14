cask "dialibgen" do
  arch arm: "arm64", intel: "x64"

  version "0.11.5"
  sha256 arm:   "f79b11ed7494a4cd00b6683f987e934b1822888efb1d6123495abb37363c0cf1",
         intel: "7f302c61a28b1166010a342caa1a41a5852a662c3e16ea336cc75f1890f0bed8"

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
