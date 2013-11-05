class TheMovie
  include HTTParty

  base_uri 'http://api.themoviedb.org/3'
  headers 'Content-Type' => 'application/json', 'Accept' => 'application/json'
  default_params output: 'json', api_key: '5b179c7589077d9923db23eb79487db6'
  format :json

  attr_accessor :name, :year, :director, :middle, :large, :backdrop,
                :tagline, :overview, :rating, :count, :actors

  def initialize(name,year,director,middle,large,backdrop,tagline,overview,rating,count,actors)
    self.name     = name
    self.year     = year
    self.director = director
    self.middle   = middle
    self.large    = large
    self.backdrop = backdrop
    self.tagline  = tagline
    self.overview = overview
    self.rating   = rating
    self.count    = count
    self.actors   = actors
  end

  def self.find(id)
    response = get("/movie/#{id.to_i}?append_to_response=casts")

    if response.success?
      self.new(
        response['title'],
        response['release_date'][0..3],
        director(response['casts']['crew']),
        poster(response['poster_path'], 'w185'),
        poster(response['poster_path'], 'w500'),
        poster(response['backdrop_path'], 'w780'),
        (response['tagline'].gsub(/(\w|\s)\.$/){$1} if response['tagline']),
        response['overview'],
        response['vote_average'],
        response['vote_count'],
        response['casts']['cast'])
    else
      nil
    end
  end

  def self.where(search)
    return unless search.present?
    escaped = CGI.escape(search)
    response = get("/search/movie?query=#{escaped}&page=1&search_type=ngram")
    response.success? ? response['results'] : nil
  end

private

  def self.poster(path, size)
    "http://d3gtl9l2a4fn1j.cloudfront.net/t/p/#{size+path}" if path
  end

  def self.director(crew)
    crew.each do |man|
      return man['name'] if man['job'] == 'Director'
    end
    nil
  end
end