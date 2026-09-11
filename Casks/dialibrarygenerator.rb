cask "dialibrarygenerator" do
  arch arm: "arm64", intel: "x64"

  version "0.2.2"
  sha256 arm:   "ae220438aa968c9b06aa48c98d40481088f97be55e2b0a43f63bf502bb5c22e5",
         intel: "8bd6c57bd729a591bffc0b52954844991c4c9b4af2952b82019f2f7212b7d90c"

  url "https://github.com/okohlbacher/DIALibraryGenerator/releases/download/v#{version}/DIALibraryGenerator-gui-macos-#{arch}.dmg"
  name "DIALibraryGenerator"
  desc "Desktop app for in-silico DIA spectral library generation from a FASTA"
  homepage "https://github.com/okohlbacher/DIALibraryGenerator"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The binaries are built with a 13.3 deployment target (libc++ shipped the
  # floating-point std::to_chars there). Homebrew's macos symbols name whole
  # releases, so :ventura would admit 13.0-13.2, where dyld refuses to load
  # them -- the cask would install and the tool would never start. Rounded UP
  # to the next release it can promise. 13.3-13.7 users can still unpack the
  # release tarball directly.
  depends_on macos: :sonoma

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
    These builds are unsigned. macOS will refuse to open this app until you
    allow it in System Settings -> Privacy & Security. See the tap README.

    The app carries its own copy of the command-line tool. Install
    dialibrarygenerator-cli only if you also want it on PATH.

    No model weights are shipped: the app needs the three AlphaPeptDeep ONNX
    exports in one directory, which its Models picker will ask for.
  EOS
end
