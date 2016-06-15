require 'net/http'
require 'uri'
require 'nokogiri'

bom_area = 'VIC_PT042'
uri = URI.parse('http://www.bom.gov.au/fwo/IDV10753.xml')

dirname = File.dirname(uri.path)
basename = File.basename(uri.path)

SCHEDULER.every '60m', :first_in => 0 do |job|
  http = Net::HTTP.new(uri.host, uri.port)
  resp = http.request(Net::HTTP::Get.new(uri.request_uri))
  forecast = Nokogiri::XML(resp.body)

  if forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='0']/element[@type='precipitation_range']").empty? then
    day_1 = {
      'name' => 'Tomorrow',
      'index' => 1,
    }
    t_plus_2 = Time.now + 2 * 24 * 3600
    day_2 = {
      'name' => t_plus_2.strftime("%A"),
      'index' => 2,
    }
  else
    day_1 = {
      'name' => 'Today',
      'index' => 0,
    }
    day_2 = {
      'name' => 'Tomorrow',
      'index' => 1,
    }
  end

  day_1['min'] =  forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='air_temperature_minimum']").first.children.first.text
  day_1['max'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='air_temperature_maximum']").first.children.first.text
  day_1['rain_chance'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/text[@type='probability_of_precipitation']").first.children.first.text
  day_1['rain_range'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='precipitation_range']").first.children.first.text
  day_1['precis'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/text[@type='precis']").first.children.first.text

  day_2['min'] =  forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='air_temperature_minimum']").first.children.first.text
  day_2['max'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='air_temperature_maximum']").first.children.first.text
  day_2['rain_chance'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/text[@type='probability_of_precipitation']").first.children.first.text
  day_2['rain_range'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='precipitation_range']").first.children.first.text
  day_2['precis'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/text[@type='precis']").first.children.first.text

  send_event('forecast_1', day_1)
  send_event('forecast_2', day_2)

end
