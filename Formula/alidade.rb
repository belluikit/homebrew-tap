class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/trendvidia/alidade"
  version "0.12.1"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in trendvidia/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.1/alidade_0.12.1_darwin_arm64.tar.gz"
      sha256 "fa77bb518ee892755bf42426a675e51fe8fd961207c3d6e77f1a6d58cd1c3c73"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.1/alidade_0.12.1_darwin_amd64.tar.gz"
      sha256 "82021790f4bb2a29da81271d7ee34e852ae64ceb8aba3b6a4f8fa6175ba25cac"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.1/alidade_0.12.1_linux_arm64.tar.gz"
      sha256 "82a1f78005870500a733838e063117aa69096522f67ba738bd373bcf0d77cec2"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.1/alidade_0.12.1_linux_amd64.tar.gz"
      sha256 "e0e8d543061b1e707a0e0e6c92c2b8a97e55901a1618beb497fb28c5bd657841"
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
