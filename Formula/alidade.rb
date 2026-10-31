class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/belluikit/alidade"
  version "0.15.0"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in belluikit/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.15.0/alidade_0.15.0_darwin_arm64.tar.gz"
      sha256 "cab38d4404de92ef3c1a995588d850d05327413ebaf1483b11796d25db048a97"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.15.0/alidade_0.15.0_darwin_amd64.tar.gz"
      sha256 "ccaddbd04d08afadee9ae0ef36bc7cf1a01c4afd9d65e79ab9fb417b634edc8b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.15.0/alidade_0.15.0_linux_arm64.tar.gz"
      sha256 "498dccad4ed9ee346dd0323b74b144c27289416a7fe363829f055443fb4a268f"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.15.0/alidade_0.15.0_linux_amd64.tar.gz"
      sha256 "985a92d479e440449bf5a3cf04845cd3fda8caa8f9033392949004191ee8e21f"
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
