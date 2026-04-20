class Gocaliper < Formula
  desc "Semantic code analysis and transformation MCP server for Go"
  homepage "https://github.com/trendvidia/gocaliper"
  license "MIT"
  head "https://github.com/trendvidia/gocaliper.git", branch: "master"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/gocaliper-mcp"
  end

  test do
    assert_predicate bin/"gocaliper", :executable?
  end
end
