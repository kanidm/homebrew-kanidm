class Kanidm < Formula
  desc "Kanidm CLI"
  version "v1.9.1"
  homepage "https://api.github.com/kanidm/kanidm/releases/latest"
  url "https://github.com/kanidm/kanidm/archive/refs/tags/#{version}.tar.gz"
  sha256 "55cdbc423a5f910ecde91db80e32c8536add25abec210764fe1d1bf1427f26b5"
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
