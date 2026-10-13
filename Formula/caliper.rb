class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.6.2.tar.gz"
  sha256 "ecd01fd9c52f4c2b73235cd2ecbde3258e44ea15b4cf554f05fb4b5ff6ca2e20"
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
