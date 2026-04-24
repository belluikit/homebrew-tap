
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.1.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "abfdbcb5740ff8c3075f5a7b910b9b9db626efc49b7c4f0cf46e90873be8e168"
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
