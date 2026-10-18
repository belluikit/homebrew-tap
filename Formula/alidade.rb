class Alidade < Formula
  desc "Code graph over MCP: Go, TypeScript, Svelte, proto, SQL, PXF and Markdown"
  homepage "https://github.com/belluikit/alidade"
  version "0.14.0"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in belluikit/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.14.0/alidade_0.14.0_darwin_arm64.tar.gz"
      sha256 "b95c4844a4b05dee25e963ae2d1032e7ef13606c5577b29daf6add8249504378"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.14.0/alidade_0.14.0_darwin_amd64.tar.gz"
      sha256 "55e23ab267b458844a524ca3d8856de46dda7ed59c152a575c6f00c1cfd9c1e8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.14.0/alidade_0.14.0_linux_arm64.tar.gz"
      sha256 "f81bb7709b08d8c4a4c68cd0fc2c512ac6cf6b5bb2277e5189d968b1f7000bf5"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.14.0/alidade_0.14.0_linux_amd64.tar.gz"
      sha256 "41c4f5c85028cb9bffe3d4ba49a12b8db7d55ebc2e11dbabd63690e2960f3d91"
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
