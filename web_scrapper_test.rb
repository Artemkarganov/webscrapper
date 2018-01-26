require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
class Scrapper

  def scrap(url)

    page = HTTParty.get(url)

    entriesArray = []

    #set the fir row of array the column names
    entriesArray << ['Title', 'Price', 'Time', 'Image', 'href']

    next_page = false

    page_num = 1

    puts 'scrapping started'

    while next_page == false

      parse_page = Nokogiri::HTML(page)

      entries = parse_page.css('.wrap').css('.offer')

      entries.each do |entry|
        begin
          image = entry.css('img.fleft')[0]['src']
        rescue NoMethodError
          puts 'Image not found'
        else
          begin
           title = entry.css('.rel>h3>a>strong')[0].text
          rescue NoMethodError
            puts "Title not found"
          else
            href = entry.css('.rel>h3>a')[0]['href']
            begin
             price = entry.css('p.price>strong')[0].text
            rescue NoMethodError
             puts "Price not found"
            else
            time = entry.css('p.x-normal')[0].text.strip

            entriesArray << [title, price, time, image, href]
            end
          end
        end
      end

        CSV.open('ad.csv', 'w+') do |csv|
          entriesArray.each do |row|
          csv << row
          end
        end

        nextLink = entries.xpath("//span[@class='fbold next abs large']/a").map { |link| link['href'] }
        if nextLink.any?
         page = HTTParty.get(url + '?page='+"#{page_num+1}")
         a = url + '?page='+"#{page_num + 1}"
         puts nextLink
          puts a
          puts "next page go go"
        else
         next_page = true
         puts "stop"
        end
        page_num += 1
      end
  end
end
scrapper = Scrapper.new
scrapper.scrap('https://www.olx.ua/zhivotnye/chk/')
#used for debugging
Pry.start(binding)
