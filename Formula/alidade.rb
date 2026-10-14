class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/trendvidia/alidade"
  version "0.12.0"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in trendvidia/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.0/alidade_0.12.0_darwin_arm64.tar.gz"
      sha256 "faca649c7f3872e6af03903c87533aed096e8321795b71007ea63265997bd609"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.0/alidade_0.12.0_darwin_amd64.tar.gz"
      sha256 "c6072b6b651158aa43bf6a4e31cb2df97e4f178c633d9bec207425ab26c209b5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.0/alidade_0.12.0_linux_arm64.tar.gz"
      sha256 "1dec380425e568229aa52a29d0f996d74d88ef02600b5b4f079fc60b73e59063"
    end
    on_intel do
      url "https://github.com/trendvidia/alidade/releases/download/v0.12.0/alidade_0.12.0_linux_amd64.tar.gz"
      sha256 "2eab00bf865c7a41e5e5690e60d763c6b5d2ec6ec60a93693fc03f12a5a2d659"
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
