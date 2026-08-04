
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.2.0.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "1a3c74f9c8a285ad0f781844ff5c9c822932f393abfbdf9107af3675b41df087"
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
