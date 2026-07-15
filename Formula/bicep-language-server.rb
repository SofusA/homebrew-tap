class BicepLanguageServer < Formula
  desc "Language server for the Bicep infrastructure-as-code language"
  homepage "https://github.com/Azure/bicep"
  url "https://github.com/Azure/bicep/releases/download/v0.45.15/bicep-langserver.zip"
  sha256 "bb652da246f9cc214e7ae371e923b0d971d681dc8b3ffc00101a38223f07acc9"
  license "MIT"

  depends_on "dotnet"

  def install
    libexec.install Dir["*"]

    current_runtime =
      if OS.mac?
        Hardware::CPU.arm? ? "osx-arm64" : "osx-x64"
      elsif Hardware::CPU.arm?
        Hardware::CPU.is_64_bit? ? "linux-arm64" : "linux-arm"
      else
        "linux-x64"
      end

    architecture_specific_runtimes = %w[
      linux-arm
      linux-arm64
      linux-x64
      osx-arm64
      osx-x64
      win-arm64
      win-x64
      win-x86
    ]

    architecture_specific_runtimes.each do |runtime|
      next if runtime == current_runtime

      rm_r(libexec/"runtimes"/runtime) if (libexec/"runtimes"/runtime).exist?
    end

    (bin/"bicep-language-server").write <<~SH
      #!/bin/bash
      exec "#{formula_opt_bin("dotnet")}/dotnet" \
        "#{libexec}/Bicep.LangServer.dll" "$@"
    SH
  end

  test do
    assert_path_exists libexec/"Bicep.LangServer.dll"
    assert_predicate bin/"bicep-language-server", :executable?

    launcher = (bin/"bicep-language-server").read
    assert_match "Bicep.LangServer.dll", launcher
    assert_match formula_opt_bin("dotnet").to_s, launcher
  end
end
