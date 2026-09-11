
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.5.0.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "76d3a88abed56a0a6c0bc4dc9a4960af2c0ac4258a2bc34badf4eac3cdb48e34"
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
