class BusytagCli < Formula
  desc "Command-line interface for BusyTag device management"
  homepage "https://github.com/busy-tag/busytag-cli"
  url "https://github.com/busy-tag/busytag-cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "0b6df397498a2c82bc5ab55b3ee6d41bdf14ecc865d901136649652b04d2b0d3"
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
    
    # Find the main project file instead of using solution
    project_file = Dir.glob("**/*.csproj").find { |f| f.include?("CLI") || f.include?("BusyTag") }
    
    if project_file.nil?
      # Fallback: look for any .csproj file
      project_file = Dir.glob("**/*.csproj").first
    end
    
    odie "No .csproj file found" if project_file.nil?
    
    # Build with optimizations using the project file directly
    system "dotnet", "publish", 
           project_file,  # Target specific project instead of solution
           "-c", "Release", 
           "-r", arch,
           "--self-contained", "true",
           "-p:PublishSingleFile=true",
           "-p:IncludeNativeLibrariesForSelfExtract=true",
           "-p:PublishTrimmed=true",
           "-p:PublishReadyToRun=true",
           "-o", "output"
    
    # Find and install the executable
    executable = Dir.glob("output/*").find { |f| File.executable?(f) && !f.end_with?(".pdb") }
    odie "No executable found in output" if executable.nil?
    
    bin.install executable => "busytag-cli"
    
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