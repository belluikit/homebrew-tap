require_relative "../private_repo"

class Go < Formula
  desc "Trendvidia \"plus\" fork of Go with extended -buildmode=plugin support"
  homepage "https://github.com/trendvidia/go"
  url "https://github.com/trendvidia/go/archive/refs/tags/v1.26.5.tar.gz",
      using: GitHubPrivateRepositoryDownloadStrategy
  sha256 "7c4f30a3b1117d05d1ebdad81afb82f51c18ad1a83843ffc1dfb916f795fbaa4"
  license "BSD-3-Clause"
  head "https://github.com/trendvidia/go.git", branch: "trendvidia"

  on_macos do
    depends_on macos: :monterey
  end

  # Installs the same `go` and `gofmt` binaries as the upstream formula.
  conflicts_with "go", because: "both install `go` and `gofmt` binaries"

  # Prebuilt upstream Go used to bootstrap make.bash. Keep in sync with
  # the upstream Homebrew go formula; only bump if it can't bootstrap.
  resource "gobootstrap" do
    checksums = {
      "darwin-arm64" => "f282d882c3353485e2fc6c634606d85caf36e855167d59b996dbeae19fa7629a",
      "darwin-amd64" => "6cc6549b06725220b342b740497ffd24e0ebdcef75781a77931ca199f46ad781",
      "linux-arm64"  => "74d97be1cc3a474129590c67ebf748a96e72d9f3a2b6fef3ed3275de591d49b3",
      "linux-amd64"  => "1fc94b57134d51669c72173ad5d49fd62afb0f1db9bf3f798fd98ee423f8d730",
    }

    version "1.24.13"

    on_arm do
      on_macos do
        url "https://go.dev/dl/go#{version}.darwin-arm64.tar.gz"
        sha256 checksums["darwin-arm64"]
      end
      on_linux do
        url "https://go.dev/dl/go#{version}.linux-arm64.tar.gz"
        sha256 checksums["linux-arm64"]
      end
    end
    on_intel do
      on_macos do
        url "https://go.dev/dl/go#{version}.darwin-amd64.tar.gz"
        sha256 checksums["darwin-amd64"]
      end
      on_linux do
        url "https://go.dev/dl/go#{version}.linux-amd64.tar.gz"
        sha256 checksums["linux-amd64"]
      end
    end
  end

  def install
    libexec.install Dir["*"]
    (buildpath/"gobootstrap").install resource("gobootstrap")
    ENV["GOROOT_BOOTSTRAP"] = buildpath/"gobootstrap"

    cd libexec/"src" do
      # Portable default C/C++ compilers for cgo. CGO_ENABLED is left
      # UNSET so this fork bakes DefaultCGO_ENABLED="" (matching upstream
      # cgo autodetection); see the fork README's "Building this fork".
      with_env(CC: "cc", CXX: "c++", CGO_ENABLED: nil) { system "./make.bash" }
    end

    bin.install_symlink Dir[libexec/"bin/go*"]

    # Remove testdata that breaks patchelf / carries non-native binaries.
    rm_r(libexec/"src/debug/elf/testdata")
    rm_r(libexec/"src/runtime/pprof/testdata")
    rm_r(libexec/"src/debug/dwarf/testdata")
  end

  test do
    # go version must identify the fork.
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

    with_env(GOOS: "freebsd", GOARCH: "amd64") do
      system bin/"go", "build", "hello.go"
    end

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

    with_env(CC: nil, CXX: nil, CGO_ENABLED: "1") do
      assert_equal "Hello from cgo!\n", shell_output("#{bin}/go run hello_cgo.go")
    end
  end
end
