
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.1.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "b78a93b46eadb62e3d8954f6a57b7e3881f66972928e5474bd13a2e90d591595"
  license "MIT"
  head "https://github.com/trendvidia/caliper.git", branch: "main"

  depends_on "go" => :build

  def install
    ENV["GOFLAGS"] = "-mod=vendor"
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/caliper-mcp"
  end

  test do
    assert_predicate bin/"caliper", :executable?
  end
end
