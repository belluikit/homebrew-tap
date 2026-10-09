require_relative "../private_repo"

class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/trendvidia/alidade"
  version "0.10.0"
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
      url "https://github.com/trendvidia/alidade/releases/download/v0.10.0/alidade_0.10.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "e253eb489e09446105e9487e2bd0647f93869393c0ab11ff0c35317ccab8e36f"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.10.0/alidade_0.10.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "056a5e1cdf04ffd406c3e4b306a68471eb4f6ae51b20fd9ab28e932ef42af733"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.10.0/alidade_0.10.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "c96b0fa49ddd91e36a3fa5e7becbb52bd918f5f24d9829e7a180b99247870781"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.10.0/alidade_0.10.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "912e123eeacb3e693149daeb5b0b7e462c50c9cc501b70fb4ac47059041d99d2"
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
