class BicepLanguageServer < Formula
  desc "Language server for the Bicep infrastructure-as-code language"
  homepage "https://github.com/Azure/bicep"
  url "https://github.com/Azure/bicep/releases/download/v0.45.15/bicep-langserver.zip"
  sha256 "bb652da246f9cc214e7ae371e923b0d971d681dc8b3ffc00101a38223f07acc9"
  license "MIT"

  depends_on "dotnet"

  def install
    libexec.install Dir["*"]

    (bin/"bicep-language-server").write <<~SH
      #!/bin/bash
      exec "#{formula_opt_bin("dotnet")}/dotnet" "#{libexec}/Bicep.LangServer.dll"
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
