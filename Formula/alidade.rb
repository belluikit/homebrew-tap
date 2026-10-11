require_relative "../private_repo"

class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/trendvidia/alidade"
  version "0.11.0"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with cgo, linking V8 for Svelte components (v0.10.0, #221): darwin
  # with clang, linux cross-compiled with zig, which needs glibc 2.29 or
  # newer. It attaches a checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.11.0/alidade_0.11.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "7ec940069212ae67fb041264f28756bf3d01b8caf689bcf98ac1ee83f1fbe865"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.11.0/alidade_0.11.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "0b73d9b2d86d7d3cf3869de5afeef74615c1f9bdf179fea214af934a99d1da86"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.11.0/alidade_0.11.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "037f3de9a097d76cd57a4148538a71214cd7cec57658ef5c584054535ecfbabc"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.11.0/alidade_0.11.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "fefbdab30fcd2e5e75e2df6993994be7b6f55a91dcb90ca3d363cf05d647172d"
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
