class Mitos < Formula
  desc "Fast and minimal selection-first modal text editor"
  homepage "https://mitos.computer"
  url "https://github.com/mitos-editor/mitos.git",
      tag:      "v0.1.0"
  license "MPL-2.0"
  head "https://github.com/mitos-editor/mitos.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Do not let the Rust build automatically fetch or compile grammars.
    # We do that explicitly after building ms.
    ENV["MITOS_DISABLE_AUTO_GRAMMAR_BUILD"] = "1"

    system "cargo", "build",
           "--release",
           "--locked",
           "--manifest-path", "crates/term/Cargo.toml"

    # Fetch and compile the Tree-sitter grammars while the source tree and
    # runtime/grammars/sources are still available.
    system "target/release/ms", "--grammar", "fetch"
    system "target/release/ms", "--grammar", "build", "--strict"

    bin.install "target/release/ms"

    # The grammar source repositories are not needed at runtime.
    rm_r "runtime/grammars/sources" if (buildpath/"runtime/grammars/sources").exist?

    libexec.install "runtime"

    # Mitos needs themes, queries, dictionaries and compiled grammars at runtime.
    bin.env_script_all_files(
      libexec/"bin",
      MITOS_RUNTIME: "${MITOS_RUNTIME:-#{libexec}/runtime}",
    )

    bash_completion.install "contrib/completion/ms.bash" => "ms"
    fish_completion.install "contrib/completion/ms.fish"
    zsh_completion.install "contrib/completion/ms.zsh" => "_ms"

    if OS.mac?
      prefix.install "contrib/Mitos.desktop" if
        (buildpath/"contrib/Mitos.desktop").exist?
    else
      (share/"applications").install "contrib/Mitos.desktop"
    end
  end

  test do
    assert_match "Mitos", shell_output("#{bin}/ms --version")
    assert_match "✓", shell_output("#{bin}/ms --health")
  end
end
