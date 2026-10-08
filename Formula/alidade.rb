require_relative "../private_repo"

class Alidade < Formula
  desc "Code intelligence over MCP: Go, .proto, SQL, .pxf and Markdown as one graph"
  homepage "https://github.com/trendvidia/alidade"
  version "0.9.0"
  license "MIT"

  # Release binaries rather than a source build: alidade's dependencies
  # (caliper, protowire-go, protocompile, chameleon) are private modules
  # Homebrew's sandbox cannot fetch, and a committed vendor tree is the
  # wrong price. The release workflow in trendvidia/alidade builds these
  # with CGO_ENABLED=0 and attaches a checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.9.0/alidade_0.9.0_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "01a34fa11486c20fca5dcf47c9b828f12397fd97c77794a5cabae1142e6e4f5d"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.9.0/alidade_0.9.0_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "5644dd1ee8b01cb66b090348801e6127b3399920b8961e083e8723beffb5e121"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.9.0/alidade_0.9.0_linux_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "9942f1d3f35a9cf9bdd49da3c1c32435a11bd495b6bba97ae5b089dd9f8995e1"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.9.0/alidade_0.9.0_linux_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "f3aef6723c87ef9fbe3d3f2ed576baefcedfc931ebfaa66ed15ca2092a5c8bc4"
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
