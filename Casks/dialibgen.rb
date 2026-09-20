cask "dialibgen" do
  arch arm: "arm64", intel: "x64"

  version "0.10.1"
  sha256 arm:   "b8d6b004e67cc6153bd0cfc45c254cd847566a924c02baa15b2e693323b3d89b",
         intel: "eb926c0bf9e462b401d8dc8178cf1361f5633c32d9fcec8a9831caa5a8d53d73"

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
