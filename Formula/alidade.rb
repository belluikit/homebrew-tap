class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/belluikit/alidade"
  version "0.13.0"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in belluikit/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.13.0/alidade_0.13.0_darwin_arm64.tar.gz"
      sha256 "cd337386466d88caa7a66745043ca555ddc48fa70e2f42800625ba9d9d52bf79"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.13.0/alidade_0.13.0_darwin_amd64.tar.gz"
      sha256 "88c5e7f1c786075220f9e02844853547abc651657b7d27a34b85c730a8bcb049"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.13.0/alidade_0.13.0_linux_arm64.tar.gz"
      sha256 "755a31399cf3fdf042a4a397c0417c391be19a9d59888a2a5a749feb8a45e09c"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.13.0/alidade_0.13.0_linux_amd64.tar.gz"
      sha256 "4a55bc545de8c49cc30ab3aed435b31e3353ca85f2ee39b8d816af3c7c6581b6"
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
