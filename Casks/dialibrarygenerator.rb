cask "dialibrarygenerator" do
  arch arm: "arm64", intel: "x64"

  version "0.0.0"
  sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
         intel: "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/okohlbacher/DIALibraryGenerator/releases/download/v#{version}/DIALibraryGenerator-gui-macos-#{arch}.dmg"
  name "DIALibraryGenerator"
  desc "Desktop app for in-silico DIA spectral library generation from a FASTA"
  homepage "https://github.com/okohlbacher/DIALibraryGenerator"

  depends_on macos: :ventura

  livecheck do
    url :url
    strategy :github_latest
  end

  app "DIALibraryGenerator.app"

  # By bundle id, so this quits ANY running DIALibraryGenerator.app, not only
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
    dialibrarygenerator-cli only if you also want it on PATH.

    No model weights are shipped: the app needs the three AlphaPeptDeep ONNX
    exports in one directory, which its Models picker will ask for.
  EOS
end
