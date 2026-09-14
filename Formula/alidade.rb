require_relative "../private_repo"

class Alidade < Formula
  desc "Code intelligence over MCP: Go, .proto, SQL, .pxf and Markdown as one graph"
  homepage "https://github.com/trendvidia/alidade"
  version "0.6.0"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with CGO_ENABLED=0 and attaches a checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.6.0/alidade_0.6.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "e3c9e0693d2d83825b275a570068e43b7ec4a5dfc4acf2e5d708320f623c1b1d"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.6.0/alidade_0.6.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "99fc155adb4796df4dbb6648977f18fce7312a6caf6e5f8cb7f5c25de52ccb9a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.6.0/alidade_0.6.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "595d2ef9649e7f9e17ee7eed2fd57d350f13b56720ddecb75dba884b48011e6a"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.6.0/alidade_0.6.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "d4f5e250cd908ae6c8807b51f6e0a83a318857293bd36e843df7fa8a225ddf8d"
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
