class KaraokeScraper
  require 'open-uri'
  require 'nokogiri'
  require 'awesome_print'
  require 'mechanize'

  attr_accessor :songs
  LANGUAGES = ["English", "Japanese", "German", "Italian", "Dutch", "French", "Spanish"]
  YEARS = [2016, 2015, 2014, 2013]

  def initialize
    @songs = []
  end

  def scrape_song_list_from_page
    url = "https://microsite.nintendo-europe.com/wiikaraokeudata/?locale=en"
    doc = Nokogiri::HTML(open(url))
    # ap doc
    doc.search('tr').each do |row|
      next if row.search('td').count == 0
      song = row.search('td')[0].text
      artist = row.search('td')[1].text
      @songs << { song: song, artist: artist}
    end
  end

end
scraper = KaraokeScraper.new
scraper.scrape_song_list_from_page
# ap scraper.songs
# 'All Songs'
# '#sel_lang', '#sel_date', '#sel_year', '#new_select_submit'
# '#new_list_arrow_r'
