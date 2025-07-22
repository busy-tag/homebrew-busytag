class BusytagCli < Formula
  desc "Command-line interface for BusyTag device management"
  homepage "https://github.com/busy-tag/busytag-cli"
  url "https://github.com/busy-tag/busytag-cli/archive/refs/tags/v0.3.5.tar.gz"
  sha256 "ceaa9cbf776437c514b7156e58b270577b86d9a4b3b4c55d2959061e82655bb9"  # This will be replaced by automation
  license "MIT"
  head "https://github.com/busy-tag/busytag-cli.git", branch: "main"

  depends_on "dotnet@8"

  def install
    # Detect architecture automatically
    arch = case Hardware::CPU.arch
           when :arm64
             "osx-arm64"
           when :x86_64
             "osx-x64"
           else
             "osx-x64"  # fallback
           end
    
    # Build with optimizations
    system "dotnet", "publish", 
           "-c", "Release", 
           "-r", arch,
           "--self-contained", "true",
           "-p:PublishSingleFile=true",
           "-p:IncludeNativeLibrariesForSelfExtract=true",
           "-p:PublishTrimmed=true",
           "-p:PublishReadyToRun=true",
           "-o", "output"
    
    # Install the executable
    bin.install "output/busytag-cli"
    
    # Ensure executable permissions
    chmod 0755, bin/"busytag-cli"
  end

  test do
    # Test version output
    version_output = shell_output("#{bin}/busytag-cli --version")
    assert_match "BusyTag CLI", version_output
    
    # Test help command
    help_output = shell_output("#{bin}/busytag-cli --help")
    assert_match "BusyTag Device Manager CLI", help_output
    
    # Test scan command (should not fail even without device)
    system "#{bin}/busytag-cli", "scan"
  end
end