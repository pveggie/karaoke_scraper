require 'awesome_print'

class KaraokeScraper
  require 'open-uri'
  require 'nokogiri'
  require 'mechanize'

  attr_reader :songs

  LANGUAGES = [
    { name: "English", value: 1 },
    { name: "Japanese", value: 0 },
    { name: "German", value: 3 },
    { name: "Italian", value: 4 },
    { name: "Dutch", value: 8 },
    { name: "French", value: 2 },
    { name: "Spanish", value: 5 }
  ]
  YEARS = [2016, 2015, 2014, 2013]
  DATE_SELECTION = { name: "All Songs", date_setting: "0000-00-00" }
  URL = "https://microsite.nintendo-europe.com/wiikaraokeudata/?locale=en"


  def initialize
    @songs = []
    @agent = Mechanize.new
    @page = @agent.get(URL)
  end

  def get_all_songs
    change_date_range_to_all
    scrape_all_pages("English")
  end

  def scrape_all_pages(language)
    page_number = 1

    loop do
      scrape_song_list_from_page(language)
      break if @page.search('#new_list_arrow_r form').empty?
      next_page(page_number += 1)
    end
  end

  def scrape_song_list_from_page(language)
    @page.search('tr').each do |row|
      next if row.search('td').count == 0
      song = row.search('td')[0].text
      artist = row.search('td')[1].text
      @songs << { song: song, artist: artist, language: language}
    end
  end

  def next_page(page_number)
   form = @page.forms.last
   form.fields[-1].value = page_number
   @page = @agent.submit(form, form.buttons.first)
  end

  def change_date_range_to_all
    form = @page.forms.first
    form.date = DATE_SELECTION[:date_setting]
    @page = @agent.submit(form, form.buttons.first)
  end

  # def test
  #   scrape_song_list_from_page("English")
  #   next_page(2)
  #   scrape_song_list_from_page("English")
  #   ap songs
  # end
end
scraper = KaraokeScraper.new
# scraper.scrape_song_list_from_page
scraper.get_all_songs
# scraper.test
ap scraper.songs
# 'All Songs'
# '#sel_lang', '#sel_date', '#sel_year', '#new_select_submit'
# '#new_list_arrow_r'
