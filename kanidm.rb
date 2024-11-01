class Kanidm < Formula
  desc "Kanidm CLI"
  version "v1.4.0"
  homepage "https://api.github.com/kanidm/kanidm/releases/latest"
  url "https://github.com/kanidm/kanidm/archive/refs/tags/#{version}.tar.gz"
  sha256 "8c2cff7116e574583e8f109e34f8e55b816c5ce5cc57bfde79b85e0ccfa94360"
  license "Mozilla Public License 2.0"
  head "https://github.com/kanidm/kanidm.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end


  depends_on "rust" => :build

  def install
    system "cargo", "install", "--bin", "kanidm", "--path", "tools/cli", "--locked", "--root", *prefix

    # Completion scripts and manpage are generated in the crate's build
    # directory, which includes a fingerprint hash. Try to locate it first
    out_dir = Dir["target/release/build/kanidm-*/out"].first
  end

  test do
    system "#{bin}/kanidm", "--version"
  end
end
