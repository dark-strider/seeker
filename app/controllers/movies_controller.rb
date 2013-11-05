# encoding: utf-8
class MoviesController < ApplicationController
  def index
    @movies = TheMovie.where(params[:search]) if params[:search].present?
  end

  def show
    @movie = TheMovie.find(params[:id])
    redirect_to :root, alert: 'Sorry... movie not found.' unless @movie
  end

  def store
    candidates = PlayMovie.where(generic(params[:name]))
    if candidates
      match_ids = match(candidates, params[:name])
      if match_ids.any?
        match_ids.each do |id|
          movie = PlayMovie.find(id)
          if movie
            if director(movie) == transformers(params[:director]) || year(movie) == params[:year]
              @google = price(movie, id)
              render partial: 'store' and return
            end
          end
        end
      end
      @related = alternative(candidates)
    end
    render partial: 'store'
  end

private
  # -Parse-

  def match(candidates, seeking)
    transformers(seeking)
    ids = []

    candidates.css('.card').each do |candidate|
      next unless name = candidate.at_css('.title').text

      if transformers(name) == seeking
        ids << candidate['data-docid'][6..-1].to_s
      end
    end
    ids
  end

  def director(movie)
    movie.css('.details-section.cast-credit tr').each do |tr|
      next unless label = tr.at_css('.cc-row-label').text

      if clear(label) == 'director'
        name = tr.at_css('.cc-row-contents a').text
        return transformers(name)
      end
    end
    ''
  end

  def year(movie)
    date = movie.at_css('.details-info .info-container .document-subtitle[itemprop=datePublished]').text
    return '' unless date.present?
    clear(date)[-4..-1]
  end

  def price(movie, id)
    price = movie.at_css('.details-wrapper .details-info .details-actions .buy-button-container .price')
    google = {
      url:   PlayMovie.base_uri + "/movies/details?id=#{id.to_s}",
      price: price.css('span').last.text }
  end

  def alternative(candidates)
    related = []
    candidates.css('.card').first(3).each do |candidate|
      break unless candidate

      related << hash = {
        url:    PlayMovie.base_uri + "/movies/details?id=#{candidate['data-docid'][6..-1].to_s}",
        name:   space(candidate.at_css('.title').text),
        price:  space(candidate.at_css('.price-container .price').text),
        poster: candidate.at_css('.cover-image')['src'] }
    end
    related
  end

  # -Regex-

  def space(line)
    line.gsub(/^\s+|\s+$/,'') if line.present?
  end

  def clear(line)
    line.downcase.gsub(/\W/,'') if line.present?
  end

  def generic(line)
    line.downcase.gsub(/\bpart (\d|i)+\b/,'') if line.present?
  end

  def transformers(line)
    return unless line.present?
    line.downcase!
    line.gsub!(/^\s*the\b\s/,'')
    line.gsub!(/&/,'and')
    line.gsub!(/\bpart \d\b/, 'part 1'=>1, 'part 2'=>2, 'part 3'=>3)
    line.gsub!(/\bpart i+\b/, 'part i'=>1, 'part ii'=>2, 'part iii'=>3)
    line.gsub!(/[\W\_]+/,'')
    line
  end
end