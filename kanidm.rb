class Kanidm < Formula
  desc "Kanidm CLI"
  version "v1.12.2"
  homepage "https://kanidm.com"
  url "https://github.com/kanidm/kanidm/archive/refs/tags/#{version}.tar.gz"
  sha256 "4ed023d39ddf304cd24d829cd6c5b90689d8e50428a043c8033fc75e813a5b47"
  license "Mozilla Public License 2.0"
  head "https://github.com/kanidm/kanidm.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    # Homebrew's systemd formula provides libudev for hardware security keys.
    depends_on "systemd"
  end

  def install
    system "cargo", "install", "--bin", "kanidm", "--path", "tools/cli", "--locked", "--root", *prefix

    # Completion scripts and manpage are generated in the crate's build
    # directory, which includes a fingerprint hash. Try to locate it first
    out_dir = Dir["target/release/build/kanidm-*/out"].first
  end

  test do
    assert_match "Usage: kanidm", shell_output("#{bin}/kanidm --help")
  end
end
