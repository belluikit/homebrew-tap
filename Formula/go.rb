require_relative "../private_repo"

class Go < Formula
  desc "Trendvidia \"plus\" fork of Go with extended -buildmode=plugin support"
  homepage "https://github.com/trendvidia/go"
  version "1.27.2"
  license "BSD-3-Clause"

  # Prebuilt toolchain archives from the release. macOS is arm64-only
  # (no Intel build is published); Linux covers arm64 and x86_64.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/go/releases/download/v1.27.2/go1.27.2-plus.darwin-arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "cd27b2d2d5887189a69704b4f26abce1e24ed815d35384d690c718d38b08d076"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/go/releases/download/v1.27.2/go1.27.2-plus.linux-arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "979f0411b66fe29f817cececa0450387f14a017353ea352a0a598d237f0b8fe5"
    end
    on_intel do
      url "https://github.com/trendvidia/go/releases/download/v1.27.2/go1.27.2-plus.linux-amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "e7bb08ba2c737f2b8cf2ca33690c56fbc8416442650bf5b9d43f6850a629b33c"
    end
  end

  # Installs the same `go` and `gofmt` binaries as the upstream formula.
  conflicts_with "go", because: "both install `go` and `gofmt` binaries"

  def install
    # The archive contains a top-level go/ tree (bin, pkg/tool, src, ...);
    # Homebrew strips it, so install the contents into libexec and expose
    # the tools. GOROOT is derived from the go binary's location.
    libexec.install Dir["*"]
    bin.install_symlink Dir[libexec/"bin/*"]

    # Drop testdata carrying non-native binaries (avoids Linux patchelf
    # relocation over foreign objects), matching the upstream formula.
    rm_r(libexec/"src/debug/elf/testdata")
    rm_r(libexec/"src/runtime/pprof/testdata")
    rm_r(libexec/"src/debug/dwarf/testdata")
  end

  test do
    # Must be the fork toolchain, and must be THIS release. The old
    # assertion only checked for "(plus)", which any fork build satisfies,
    # so a stale url/sha pair would still have passed. forkVersionMarker in
    # the toolchain names the release tag, so pin to it via version.
    assert_match "(plus v#{version})", shell_output("#{bin}/go version")

    (testpath/"hello.go").write <<~GO
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    GO

    system bin/"go", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go run hello.go")

    (testpath/"hello_cgo.go").write <<~GO
      package main

      /*
      #include <stdlib.h>
      #include <stdio.h>
      void hello() { printf("%s\\n", "Hello from cgo!"); fflush(stdout); }
      */
      import "C"

      func main() {
          C.hello()
      }
    GO

    with_env(CGO_ENABLED: "1") do
      assert_equal "Hello from cgo!\n", shell_output("#{bin}/go run hello_cgo.go")
    end
  end
end
