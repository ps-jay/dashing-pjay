require 'net/http'
require 'uri'
require 'nokogiri'

uri = URI.parse('https://www.sbs.com.au/news/feed')

SCHEDULER.every '60m', :first_in => 0 do |job|
  headlines = []

  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request

      rss = Nokogiri::XML(response.body)
      for title in rss.xpath("//item//title") do
        headlines += [title.text]
      end
  end

  send_event('ticker', {:items => headlines})
end
