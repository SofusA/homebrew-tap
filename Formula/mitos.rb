class Mitos < Formula
  desc "Fast and minimal text editor"
  homepage "https://mitos.computer"
  url "https://github.com/mitos-editor/mitos/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "9ee73831c2a55e2100cbed31721f9275ca689cf8a7304d58c4c32ebe9473eab6"
  license "MPL-2.0"

  head "https://github.com/mitos-editor/mitos.git", branch: "main"

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    system "cargo", "run", "--locked", "--package", "grammar-build", "--bin", "grammar-fetch"
  end

  def install
    # Build the fetched grammars explicitly without trying to fetch them again.
    ENV["MITOS_DISABLE_AUTO_GRAMMAR_BUILD"] = "1"
    ENV["CARGO_MANIFEST_DIR"] = buildpath/"crates/term"

    system "cargo", "install", "-vv", *std_cargo_args(path: "crates/term")
    system bin/"ms", "--grammar", "build", "--strict"
    rm_r "runtime/grammars/sources/"
    libexec.install "runtime"
    bin.env_script_all_files libexec/"bin", MITOS_RUNTIME: "${MITOS_RUNTIME:-#{libexec}/runtime}"

    bash_completion.install "contrib/completion/ms.bash" => "ms"
    fish_completion.install "contrib/completion/ms.fish"
    zsh_completion.install "contrib/completion/ms.zsh" => "_ms"
  end

  test do
    assert_match "Mitos terminal application", shell_output("#{bin}/ms --help")
    assert_match "✓", shell_output("#{bin}/ms --health")
  end
end
