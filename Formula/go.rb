require_relative "../private_repo"

class Go < Formula
  desc "Trendvidia \"plus\" fork of Go with extended -buildmode=plugin support"
  homepage "https://github.com/trendvidia/go"
  version "1.26.5"
  license "BSD-3-Clause"

  # Prebuilt toolchain archives from the release. macOS is arm64-only
  # (no Intel build is published); Linux covers arm64 and x86_64.
  on_macos do
    on_arm do
      url "https://github.com/trendvidia/go/releases/download/v1.26.5/go1.26.5-plus.darwin-arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "e9e49df763654c3678479ea2624ed733b37551029a3e48e7bec8fa874d4f600e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/trendvidia/go/releases/download/v1.26.5/go1.26.5-plus.linux-arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "5d2c96efa25a053cc2633dfec147f310ef064ce2d1f00fe84873237004a29dbe"
    end
    on_intel do
      url "https://github.com/trendvidia/go/releases/download/v1.26.5/go1.26.5-plus.linux-amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "5748b3e46e6cf0ceba3d3ff09956ed734d17c5a293ad64b5aba472271975e9af"
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
    # Must be the fork toolchain.
    assert_match "(plus)", shell_output("#{bin}/go version")

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
