class BusytagCli < Formula
  desc "Command-line interface for BusyTag device management"
  homepage "https://github.com/busy-tag/busytag-cli"
  url "https://github.com/busy-tag/busytag-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "2bbc73145d9f8da4be5dbe08bc7765a9ced94d55f8b23989d3385ce8df10c921"  # Calculate with: shasum -a 256 v1.0.0.tar.gz
  license "MIT"
  head "https://github.com/busy-tag/busytag-cli.git", branch: "main"

  depends_on "dotnet@8"

  def install
    # Detect architecture
    arch = Hardware::CPU.arm? ? "osx-arm64" : "osx-x64"
    
    # Build self-contained executable
    system "dotnet", "publish", 
           "-c", "Release", 
           "-r", arch,
           "--self-contained", "true",
           "-p:PublishSingleFile=true",
           "-p:IncludeNativeLibrariesForSelfExtract=true",
           "-p:PublishTrimmed=true",
           "-o", "output"
    
    # Install the native executable (not .dll)
    bin.install "output/busytag-cli"
    
    # Make sure it's executable
    chmod 0755, bin/"busytag-cli"
  end

  test do
    # Test that the binary runs and shows version
    assert_match version.to_s, shell_output("#{bin}/busytag-cli --version")
    
    # Test help command
    assert_match "BusyTag Device Manager CLI", shell_output("#{bin}/busytag-cli --help")
    
    # Test scan command (should not fail even without device)
    system "#{bin}/busytag-cli", "scan"
  end
end