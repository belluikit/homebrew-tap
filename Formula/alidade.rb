class Alidade < Formula
  desc "Code graph over MCP: Go, Rust, Python, TypeScript, Svelte, proto, SQL and more"
  homepage "https://github.com/belluikit/alidade"
  version "0.16.0"
  license "MIT"

  # Release binaries rather than a source build: alidade links V8, for
  # Svelte components, and CPython, for Python calls, so every target is a
  # cgo build against prebuilt static libraries, darwin with clang and
  # linux cross-compiled with zig, which needs glibc 2.29 or newer. The
  # release workflow in belluikit/alidade builds them and attaches a
  # checksums file next to them.
  on_macos do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.16.0/alidade_0.16.0_darwin_arm64.tar.gz"
      sha256 "2875e83639b8287d5788e792e3af312861a3493ee7ef1320601c18c9a1acbdfe"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.16.0/alidade_0.16.0_darwin_amd64.tar.gz"
      sha256 "39c766dd90275f7f1843691b14d312efcb28b1a1070770414bc35c28bd0c79b4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/belluikit/alidade/releases/download/v0.16.0/alidade_0.16.0_linux_arm64.tar.gz"
      sha256 "74e29f1e3f7bbc61684c41cbc60b9a652c6f6bf28e993c67cb254c29c0e4783a"
    end
    on_intel do
      url "https://github.com/belluikit/alidade/releases/download/v0.16.0/alidade_0.16.0_linux_amd64.tar.gz"
      sha256 "0ed8244dcff371e00b8e799bccaaa8351659e8a3aaf865f3c2f5919f2bb7b680"
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

      Analysing Go needs a Go toolchain on PATH. Analysing Rust needs
      rust-analyzer and the standard library source, from rustup:
        rustup component add rust-analyzer rust-src
      The other layers need nothing installed.
    EOS
  end

  test do
    assert_match "usage: alidade", shell_output("#{bin}/alidade help")
    # An empty directory builds an empty graph: exercises the pipeline
    # without a toolchain.
    assert_match "stats", shell_output("#{bin}/alidade graph -root #{testpath}")
  end
end
