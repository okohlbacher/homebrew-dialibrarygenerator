class Dialibrarygenerator < Formula
  desc "In-silico DIA spectral library generation from a FASTA"
  homepage "https://github.com/okohlbacher/DIALibraryGenerator"
  version "0.2.1"
  license "BSD-3-Clause"

  # A FORMULA, not only a cask, and this is the reason: Homebrew registers a
  # cask download with syspolicyd, and Gatekeeper then denies an un-notarized
  # payload -- silently, by stopping the process inside dyld before main, at 0%
  # CPU, forever. Stripping com.apple.quarantine afterwards does not help (the
  # provenance record is what is consulted) and Homebrew 6 removed the
  # --no-quarantine escape hatch. A formula's download is not registered that
  # way, so the same bytes run.
  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/DIALibraryGenerator/releases/download/v0.2.1/DIALibraryGenerator-macos-arm64.tar.gz"
      sha256 "77303fff3d2c47fdb3ea1aa3cc731f0912f605341f26cd5b6c7eedefdeefebc1"
    end
    on_intel do
      url "https://github.com/okohlbacher/DIALibraryGenerator/releases/download/v0.2.1/DIALibraryGenerator-macos-x64.tar.gz"
      sha256 "66ae589035d0173b2cbaec615fb5475e93bfb41f6064c42fd2a29efc771a368e"
    end
  end

  def install
    # Everything into libexec, then ONE wrapper on PATH. Not bin.install: the
    # tree carries 147 dylibs and its own share/OpenMS, and linking those into
    # the Homebrew prefix would collide with every other formula that ships an
    # Arrow or a Qt.
    libexec.install Dir["*"]
    # write_env_script execs the ABSOLUTE libexec path, so the tool's own
    # <exe>/../share lookup and its @executable_path/../lib dylib closure both
    # resolve inside libexec. A plain symlink into bin would point both at the
    # Homebrew prefix, where neither exists.
    (bin/"DIALibraryGenerator").write_env_script libexec/"bin/DIALibraryGenerator", {}
  end

  def caveats
    <<~EOS
      No model weights are shipped. DIALibraryGenerator needs the three
      AlphaPeptDeep ONNX exports (peptdeep_{rt,ms2,ccs}_dynamic.onnx) in one
      directory, named by DIALIBGEN_MODEL_DIR or in the config file.
    EOS
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/DIALibraryGenerator --help 2>&1")
    system bin/"DIALibraryGenerator", "-write_config", "eff.json"
    assert_path_exists testpath/"eff.json"
  end
end
