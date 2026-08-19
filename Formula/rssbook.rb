class Rssbook < Formula
  desc "Tool for converting rss feeds into epub books"
  homepage "https://github.com/sofusa/rssbook"
  license "GPL-3.0"
  head "https://github.com/sofusa/rssbook.git", branch: "main"

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "rssbook", shell_output("#{bin}/rssbook --help")
  end
end
