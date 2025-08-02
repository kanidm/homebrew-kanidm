class Kanidm < Formula
  desc "Kanidm CLI"
  version "v1.7.0"
  homepage "https://api.github.com/kanidm/kanidm/releases/latest"
  url "https://github.com/kanidm/kanidm/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "9327f609cd8b5007d28a3cd5bd4c8fc2a1a5b88375cb77deb9f1f097ac49ddb4"
  license "Mozilla Public License 2.0"
  head "https://github.com/kanidm/kanidm.git", branch: "master"

  livecheck do
    url "https://github.com/kanidm/kanidm/archive/refs/tags/v1.7.0.tar.gz"
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
