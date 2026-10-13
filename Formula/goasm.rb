class Goasm < Formula
  desc "Generate Go JIT emitter methods from assembly templates"
  homepage "https://github.com/trendvidia/goasm"
  url "https://github.com/trendvidia/goasm/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "c86d4672e1ace607608c0717e86b5383f3d6cc2d5cf510a31431ad53fbf90028"
  license "MIT"
  head "https://github.com/trendvidia/goasm.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/goasm"
  end

  test do
    (testpath/"t.goasm").write <<~GOASM
      # ALIAS SP = X21

      # TEMPLATE PushInt(reg int)
          STR  reg, [SP, #0]
          ADD  SP, SP, #8
    GOASM
    system bin/"goasm", "-arch", "arm64", "-in", "t.goasm", "-out", "emit.go", "-pkg", "demo"
    assert_match "func (e *Emitter) EmitPushInt(reg int)", (testpath/"emit.go").read
  end
end
