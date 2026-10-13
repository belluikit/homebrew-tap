class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.6.1.tar.gz"
  sha256 "7ff3440b2098d2a14e78743ae436431d9aedc6e50ab6cfa8e86d06e1af776d52"
  license "MIT"
  head "https://github.com/trendvidia/caliper.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"caliper"),
           "./cmd/caliper-mcp"
    system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"caliper-analyze"),
           "./cmd/caliper-analyze"
  end

  test do
    assert_predicate bin/"caliper", :executable?
    assert_match version.to_s, shell_output("#{bin}/caliper-analyze -version")
  end
end
