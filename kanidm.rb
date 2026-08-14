class Kanidm < Formula
  desc "Kanidm CLI"
  version "v1.11.1"
  homepage "https://kanidm.com"
  url "https://github.com/kanidm/kanidm/archive/refs/tags/#{version}.tar.gz"
  sha256 "de548f4a20e9b23d3e7ddf6b7bf17f8310fb430a7211e22dc13058240264e978"
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
