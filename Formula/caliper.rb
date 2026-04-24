
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.15.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "b8555da625f467f53a5478d88ad19a14e2af87d87db654bac1e6c2c789335c45"
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
