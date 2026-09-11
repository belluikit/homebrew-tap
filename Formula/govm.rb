require_relative "../private_repo"

class Govm < Formula
  desc "Go virtual machine: compiles Go source to bytecode and runs it with a JIT"
  homepage "https://github.com/trendvidia/govm"
  url "https://github.com/trendvidia/govm/archive/refs/tags/v2.14.0.tar.gz",
      using: GitHubPrivateRepositoryDownloadStrategy
  sha256 "a8f3aba0a11999327e5e981cd3a1c8201c58b137b483f4293d688b59881305fa"
  head "https://github.com/trendvidia/govm.git", branch: "main"

  # Not a build-only dependency: the compiler frontend type-checks guest source
  # with go/parser + go/types, so it needs a GOROOT at runtime. It is the fork
  # rather than core Go because the module plugins below need the extended
  # -buildmode=plugin support, and a plugin must be built with the same
  # toolchain as the host binary that loads it.
  depends_on "trendvidia/tap/go"

  # The loadable modules (crypto, os, os/exec, filepath, net/http, protowire,
  # rpc). Each is a `main` package behind the `plugin` build tag, exporting
  # GoVMRegister/GoVMManifest.
  MODULES = %w[crypto exec filepath nethttp os protobuf rpc].freeze

  # go.mod requires the private github.com/trendvidia/ironclad/sdk module, and
  # `go build` cannot fetch it: Homebrew strips every token-like variable from
  # the environment before the build runs, so HOMEBREW_GITHUB_API_TOKEN is gone
  # by then. Vendor it as a resource instead — resources are fetched up front by
  # the same authenticated download strategy as the formula itself — and point
  # go.mod at the staged copy. Its own dependencies are all public.
  resource "ironclad-sdk" do
    url "https://github.com/trendvidia/ironclad/archive/refs/tags/sdk/v0.1.0.tar.gz",
        using: GitHubPrivateRepositoryDownloadStrategy
    sha256 "e171fe87c847e7bbec00d91f92e9f14645ebf503b88d68dc234a6d9615f5a231"
  end

  def install
    (buildpath/"ironclad").install resource("ironclad-sdk")
    system "go", "mod", "edit",
           "-replace", "github.com/trendvidia/ironclad/sdk=#{buildpath}/ironclad/sdk"
    ENV["GOFLAGS"] = "-mod=mod" # the replace above has to be resolvable

    # Never swap in a downloaded toolchain: the plugins have to be built by the
    # very toolchain that builds the host binary.
    ENV["GOTOOLCHAIN"] = "local"

    # Deliberately NOT std_go_args: its -trimpath strips the GOROOT baked into
    # the binary, and without it `govm run` cannot resolve stdlib imports
    # ("could not import fmt ... $GOROOT not set"). The plugins get the exact
    # same flags — a mismatch makes plugin.Open reject them at load time.
    ldflags = "-s -w"
    system "go", "build", "-ldflags=#{ldflags}", "-o", libexec/"govm", "."

    MODULES.each do |mod|
      system "go", "build", "-ldflags=#{ldflags}", "-tags", "plugin", "-buildmode=plugin",
             "-o", libexec/"modules/#{mod}.so", "./modules/#{mod}/plugin"
      # Companion manifest: the loader prefers the plugin's GoVMManifest export
      # and falls back to <name>.pxf next to the .so.
      (libexec/"modules").install "modules/#{mod}/plugin/#{mod}.pxf"
    end

    # The GOROOT baked in at build time points into the Cellar path of the
    # exact Go version used, so it breaks on the next `brew upgrade go`. Pin it
    # to the fork's stable opt path instead, while still letting a caller
    # override GOROOT to type-check guests against a different stdlib.
    goroot = formula_opt_libexec("trendvidia/tap/go")
    (bin/"govm").write <<~SH
      #!/bin/bash
      export GOROOT="${GOROOT:-#{goroot}}"
      exec "#{libexec}/govm" "$@"
    SH
    (bin/"govm").chmod 0755
  end

  def caveats
    <<~EOS
      The loadable modules are installed to:
        #{opt_libexec}/modules

      govm auto-loads plugins only from ~/.govm/modules, so link them there:
        mkdir -p ~/.govm/modules
        ln -sf #{opt_libexec}/modules/* ~/.govm/modules/

      or load one explicitly:
        govm --module #{opt_libexec}/modules/nethttp.so --allow-all run script.go

      run/debug/dap are sandboxed by default, and the sandbox skips plugins —
      pass --allow-all or a granular --allow-* grant to use a module. Guest
      scripts import modules by their registered path ("filepath", "os",
      "os/exec", "crypto", "net/http", "protowire", "rpc").

      Rebuild (`brew reinstall govm`) after upgrading trendvidia/tap/go: Go
      plugins only load into a host built by the same toolchain.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/govm version")

    (testpath/"hello.go").write <<~GO
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    GO

    assert_equal "Hello World\n", shell_output("#{bin}/govm --no-cache run hello.go")

    # A plugin only opens if it matches the host binary's toolchain and build
    # flags, so this covers the fragile part of the build.
    (testpath/"module.go").write <<~GO
      package main

      import (
          "fmt"
          "filepath"
      )

      func main() {
          fmt.Println(filepath.Join("a", "b"))
      }
    GO

    output = shell_output(
      "#{bin}/govm --module #{libexec}/modules/filepath.so --allow-all --no-cache run module.go",
    )
    assert_equal "a/b\n", output
  end
end
