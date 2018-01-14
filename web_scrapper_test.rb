require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
require 'csv'

page = HTTParty.get('https://www.olx.ua/zhivotnye/sobaki/chk/')

parse_page = Nokogiri::HTML(page)

entries = parse_page.css('.wrap').css('.offer')

entriesArray = []

entries.each do |entry|

  image = entry.css('img.fleft')[0]['src']
  title = entry.css('.rel>h3>a>strong').text
  href = entry.css('.rel>h3>a')[0]['href']
  price = entry.css('p.price>strong')[0].text
  time = entry.css('p.x-normal')[0].text


  entriesArray << image
  entriesArray << title
  entriesArray << href
  entriesArray << price
  entriesArray << time
end

entries


CSV.open('ad.csv', 'w') do |csv|
  csv << entriesArray
end

#used for debugging
Pry.start(binding)
