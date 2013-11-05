class PlayMovie
  include HTTParty
  parser NokogiriParser

  base_uri 'https://play.google.com/store'
  headers 'Content-Type' => 'text/html', 'Accept' => 'text/html'
  default_params output: 'html'
  format :html

  def self.find(id)
    response = get("/movies/details?id=#{id.to_s}")
    response.success? ? response.at_css('#body-content') : nil
  end

  def self.where(name)
    return unless name.present?
    escaped = CGI.escape(name)
    response = get("/search?q=#{escaped}%26amp%3Bc=movies%26amp%3BdocType=6%26amp%3Bnum=10")
    response.success? ? response.at_css('.card-list') : nil
  end
end

# base_uri 'http://webprox-01.123locker.com/index.php?q=https://play.google.com/store' # US-proxy
# https://play.google.com/store/search?q=serenity&c=movies&docType=6&num=7
# https://play.google.com/store/movies/details?id=hxyciMFm7n8