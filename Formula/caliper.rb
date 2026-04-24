
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.12.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "a713f4492f063810d8ceb72476e1e8c9658199c8693d040288669dc19fc37100"
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
