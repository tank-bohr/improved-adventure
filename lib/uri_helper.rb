require 'uri'

module UriHelper
  def normalize_url(base_url, url)
    uri = URI(url)
    if uri.relative?
      base_uri = URI(base_url)
      uri = if '/' == base_uri.normalize.path
        URI.join(base_url, url)
      else
        URI.join("#{base_url}/..", url)
      end
    end
    uri.normalize.to_s
  end
end
