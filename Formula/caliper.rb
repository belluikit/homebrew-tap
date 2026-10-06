
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.6.0.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "69946555b5517833a49b1d2e9210a374f8afe53b9bc652d4b087e30236c9e12f"
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
