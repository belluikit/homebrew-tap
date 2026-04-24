
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.0.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "73df7d6e0d1e5b5dcf4db93badd33718d3f0e897565278f69a777797b898423e"
  license "MIT"
  head "https://github.com/trendvidia/caliper.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/caliper-mcp"
  end

  test do
    assert_predicate bin/"caliper", :executable?
  end
end
