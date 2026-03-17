class BusytagCli < Formula
  desc "Command-line interface for BusyTag device management"
  homepage "https://github.com/busy-tag/busytag-cli"
  url "https://github.com/busy-tag/busytag-cli/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "e5fc5b469240eb11a21b3b616875addf0663da0e20f7a4f852879fcebff67ee5"  # This will be replaced by automation
  license "MIT"
  head "https://github.com/busy-tag/busytag-cli.git", branch: "master"

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
    
    # Build only the CLI project (not the full solution, which references the submodule)
    system "dotnet", "publish",
           "BusyTag.CLI/BusyTag.CLI.csproj",
           "-c", "Release",
           "-r", arch,
           "--self-contained", "true",
           "-p:PublishSingleFile=true",
           "-p:IncludeNativeLibrariesForSelfExtract=true",
           "-p:PublishTrimmed=true",
           "-p:PublishReadyToRun=true",
           "-o", "output"
    
    # Install the executable and bundled esptool
    bin.install "output/busytag-cli"
    (bin/"Tools").install Dir["output/Tools/*"]

    # Ensure executable permissions
    chmod 0755, bin/"busytag-cli"
    chmod 0755, bin/"Tools/macos/esptool" if (bin/"Tools/macos/esptool").exist?
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