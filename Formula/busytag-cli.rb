class BusytagCli < Formula
  desc "Command-line interface for BusyTag device management"
  homepage "https://github.com/busy-tag/busytag-cli"
  url "https://github.com/busy-tag/busytag-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a011b41aaa9aca51def6d7bb102558d204e3ee08"  # Calculate with: shasum -a 256 v1.0.0.tar.gz
  license "MIT"
  head "https://github.com/busy-tag/busytag-cli.git", branch: "main"

  depends_on "dotnet@8"

  def install
    # Build the application
    system "dotnet", "publish", "-c", "Release", "-r", "osx-x64", 
           "--self-contained", "false", "-o", "output"
    
    # Install to bin
    bin.install "output/busytag-cli"
  end

  test do
    system "#{bin}/busytag-cli", "--version"
  end
end
