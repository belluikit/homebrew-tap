
require_relative "../private_repo" 

class Caliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/caliper"
  url "https://github.com/trendvidia/caliper/archive/refs/tags/v1.0.11.tar.gz",
      :using => GitHubPrivateRepositoryDownloadStrategy
  sha256 "92831c6701f19e81340ae7778d842d1c38be0bd3b1a74d92cf688624f838037a"
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
