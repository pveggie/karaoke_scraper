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
    puts "This will take a while."
    LANGUAGES.each do |language|
      puts "Collecting songs for #{language[:name]}"
      YEARS.each do |year|
        puts "#{language[:name]} - added in #{year}"
        set_year_date_and_language(year, language[:value])
        scrape_all_pages(language[:name])
      end
      puts "#{language[:name]} finished."
    end
  end

  private

  def scrape_all_pages(language)
    page_number = 1

    loop do
      puts "Page #{page_number}"
      scrape_song_list_from_page(language)
      break if @page.search('#new_list_arrow_r form').empty?
      next_page(page_number += 1)
    end
  end

  def set_year_date_and_language(year, language_value)
    form = @page.forms.first
    form.date = DATE_SELECTION[:date_setting]
    form.year = year
    form.song_lang = language_value
    @page = @agent.submit(form, form.buttons.first)
  end

  def scrape_song_list_from_page(language)
    @page.search('tr').each do |row|
      next if row.search('td').count == 0
      title = row.search('td')[0].text
      artist = row.search('td')[1].text
      @songs << { title: title, artist: artist, language: language }
    end
  end

  def next_page(page_number)
   form = @page.forms.last
   puts "Form data: #{form.year} - #{form.date} - #{form.song_lang}"
   form.fields[-1].value = page_number
   @page = @agent.submit(form, form.buttons.first)
  end
end

scraper = KaraokeScraper.new
scraper.get_all_songs
puts "Songs collected. Writing to csv file"

require 'csv'

CSV.open(
  "song_list.csv",
  "wb",
  write_headers: true,
  headers: ["Title", "Artist", "Language"],
  col_sep: ";"
  ) do |csv|
  scraper.songs.each do |song|
    csv << [song[:title], song[:artist], song[:language]]
  end
end

puts "Finished. Check 'song_list.csv' to see the songs."
