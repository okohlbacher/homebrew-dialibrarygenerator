cask "dialibrarygenerator" do
  arch arm: "arm64", intel: "x64"

  version "0.2.1"
  sha256 arm:   "d24c0095d4a14deb1b1ba0147c144d6b5d21586a76b29a7733026c5874310fef",
         intel: "cded4f02373b207fb100488cae2cb6a851f4d316d8b2ea9d994e1a13f74683f5"

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
    NOT NOTARIZED. macOS will refuse to open this app until you allow it in
    System Settings -> Privacy & Security. See the tap README.

    The app carries its own copy of the command-line tool. Install
    dialibrarygenerator-cli only if you also want it on PATH.

    No model weights are shipped: the app needs the three AlphaPeptDeep ONNX
    exports in one directory, which its Models picker will ask for.
  EOS
end
