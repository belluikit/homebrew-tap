class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    set_github_token
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN is required."
    end
  end

  def _fetch(url:, resolved_url:, timeout:)
    # Adds the token to the curl command headers
    curl_download resolved_url, "--header", "Authorization: token #{@github_token}", to: temporary_path
  end
end

