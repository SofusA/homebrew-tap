class TextWallpaper < Formula
  desc "Generate wallpapers containing custom text"
  homepage "https://github.com/SofusA/text-wallpaper"
  url "https://github.com/SofusA/text-wallpaper/archive/bdbaeef465fb852ca3020c86a27d1c8d887eb883.tar.gz"
  version "0.1.0"
  sha256 "173fc6527e7a79dea94ca287cb4260bbbfff73030f48d0a6befc9d0ce18016cb"
  head "https://github.com/SofusA/text-wallpaper.git", branch: "main"

  depends_on "rust" => :build
  depends_on :linux

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "text-wallpaper", shell_output("#{bin}/text-wallpaper --help")
  end
end
