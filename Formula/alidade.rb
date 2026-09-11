require_relative "../private_repo"

class Alidade < Formula
  desc "Code intelligence over MCP: Go, .proto, SQL, .pxf and Markdown as one graph"
  homepage "https://github.com/trendvidia/alidade"
  version "0.3.0"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with CGO_ENABLED=0 and attaches a checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.3.0/alidade_0.3.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "a411026d11212c40b7afcf186624cb0869f3943d6fd73d4c83453d9a4331f56a"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.3.0/alidade_0.3.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "175dc111c8c1f7b10706d65dcf6ea0500d57f3cab2a6be57c08b275c994d0ff3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.3.0/alidade_0.3.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "44928476c72cfb0e3271e15ec6e3b05c5a2a7e51523a6f5b11d1c2af2976f40b"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.3.0/alidade_0.3.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "41f9a7541045acc384c6b4463af73624463bbc0bee68090df3c70aaed812a07f"
    end
  end

  def install
    bin.install "alidade"
  end

  def caveats
    <<~EOS
      To connect Claude Code (one registration serves every repository):
        alidade setup

      For any other MCP client, print the configuration with:
        alidade setup -print

      Analysing Go needs a Go toolchain on PATH; the other layers do not.
    EOS
  end

  test do
    assert_match "usage: alidade", shell_output("#{bin}/alidade help")
    # An empty directory builds an empty graph: exercises the pipeline
    # without a toolchain.
    assert_match "stats", shell_output("#{bin}/alidade graph -root #{testpath}")
  end
end
