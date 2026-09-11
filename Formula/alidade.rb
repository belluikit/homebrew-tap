require_relative "../private_repo"

class Alidade < Formula
  desc "Whole-repository code intelligence: Go, .proto, SQL, .pxf and Markdown as one graph, over MCP"
  homepage "https://github.com/trendvidia/alidade"
  version "0.1.1"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with CGO_ENABLED=0 and attaches a checksums file next to them.
  on_arm do
    url "https://github.com/trendvidia/alidade/releases/download/v0.1.1/alidade_0.1.1_darwin_arm64.tar.gz",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "6f011d91d550368f29e922e8a9c9cf7d60d231b0db61360770a06f397738f3e1"
  end
  on_intel do
    url "https://github.com/trendvidia/alidade/releases/download/v0.1.1/alidade_0.1.1_darwin_amd64.tar.gz",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "b46f6652c96f88535c10093b3292df0dedcf71a7de6ed5ead3c31377aaa58266"
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
