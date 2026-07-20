# typed: strict
# frozen_string_literal: true

# These two related GitHub private-repo download strategies live together.
# rubocop:disable Style/OneClassPerFile

# Download strategy for a source archive from a private GitHub repository,
# adding the token from HOMEBREW_GITHUB_API_TOKEN to the request.
class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    set_github_token
  end

  def set_github_token
    @github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
    return if @github_token

    raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN is required."
  end

  def _fetch(url:, resolved_url:, timeout:)
    # Adds the token to the curl command headers
    curl_download resolved_url, "--header", "Authorization: token #{@github_token}", to: temporary_path
  end
end

# Download strategy for assets attached to a GitHub release in a private
# repository. The browser download URL does not accept a bearer token
# for private repos, so we resolve the asset's numeric id via the API
# and fetch it from the asset endpoint with `Accept: application/octet-stream`.
# URL form: https://github.com/<owner>/<repo>/releases/download/<tag>/<file>
class GitHubPrivateRepositoryReleaseDownloadStrategy < GitHubPrivateRepositoryDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
  end

  def parse_url_pattern
    url_pattern = %r{https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    raise CurlDownloadStrategyError, "Invalid GitHub release URL: #{@url}" unless @url&.match?(url_pattern)

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def _fetch(url:, resolved_url:, timeout:)
    curl_download asset_endpoint,
                  "--header", "Accept: application/octet-stream",
                  "--header", "Authorization: token #{@github_token}",
                  to: temporary_path
  end

  private

  def asset_endpoint
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  def asset_id
    @asset_id ||= begin
      require "utils/github"
      release = GitHub::API.open_rest(
        "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}",
      )
      asset = release.fetch("assets", []).find { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Asset #{@filename} not found in #{@tag}." if asset.nil?

      asset["id"]
    end
  end
end
# rubocop:enable Style/OneClassPerFile
