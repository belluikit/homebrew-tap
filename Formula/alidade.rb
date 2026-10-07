require_relative "../private_repo"

class Alidade < Formula
  desc "Code intelligence over MCP: Go, .proto, SQL, .pxf and Markdown as one graph"
  homepage "https://github.com/trendvidia/alidade"
  version "0.7.0"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with CGO_ENABLED=0 and attaches a checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.7.0/alidade_0.7.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "8c825f8de400ef55c565499474a9f37b245d6da048f08ecf1a2bb29df2516016"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.7.0/alidade_0.7.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "89927302c6fa674f1b3d510030652b7c58fa9f5a99f84ef2f791da596c8b2d66"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.7.0/alidade_0.7.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "21b0085f6120121c950528ef77f24700895f5e557c39960eb990f2ef7fbc8747"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.7.0/alidade_0.7.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "a67e7b8d5b2aafb94718408716b1f406afb1e686bc6b17c85f0a5a763b7b20c4"
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
