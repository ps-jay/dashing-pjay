require 'net/http'
require 'time'
require 'uri'
require 'nokogiri'

bom_area = 'VIC_PT042'
uri = URI.parse('http://www.bom.gov.au/fwo/IDV10753.xml')

SCHEDULER.every '60m', :first_in => 0 do |job|
  http = Net::HTTP.new(uri.host, uri.port)
  resp = http.request(Net::HTTP::Get.new(uri.request_uri))
  forecast = Nokogiri::XML(resp.body)

  end_time_index_0 = Time.iso8601(forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='0']").first.attributes['end-time-local'].value)

  if Time.now < end_time_index_0 then
    if Time.now.hour < 16 then
      # Forecast was issued today, and it's before 4pm - show today and tomorrow
      day_1 = {
        'name' => 'Today',
        'index' => 0,
      }
      day_2 = {
        'name' => 'Tomorrow',
        'index' => 1,
      }
    else
      # Forecast was issued today, and it's after 4pm - show tomorrow and the next day
      day_1 = {
        'name' => 'Tomorrow',
        'index' => 1,
      }
      t_plus_2 = Time.now + 2 * 24 * 3600
      day_2 = {
        'name' => t_plus_2.strftime("%A"),
        'index' => 2,
      }
    end
  else
    # Forecast was issued yesterday - show today and tomorrow
    day_1 = {
      'name' => 'Today',
      'index' => 1,
    }
    day_2 = {
      'name' => 'Tomorrow',
      'index' => 2,
    }
  end

  day_1['min'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='air_temperature_minimum']").first.children.first.text
  day_1['max'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='air_temperature_maximum']").first.children.first.text
  day_1['rain_chance'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/text[@type='probability_of_precipitation']").first.children.first.text
  day_1['precis'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/text[@type='precis']").first.children.first.text

  day_2['min'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='air_temperature_minimum']").first.children.first.text
  day_2['max'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='air_temperature_maximum']").first.children.first.text
  day_2['rain_chance'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/text[@type='probability_of_precipitation']").first.children.first.text
  day_2['precis'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/text[@type='precis']").first.children.first.text

  # Adjust rain forecast to avoid "0% change of 0mm of rain" and the like...
  if day_1['rain_chance'] == '0%' or day_1['rain_range'] == '0 mm' then
    day_1['rain_forecast'] = 'No rain.'
  else
    begin
      day_1['rain_range'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_1['index']}']/element[@type='precipitation_range']").first.children.first.text
    rescue
      day_1['rain_range'] = 'some'
    end
    day_1['rain_forecast'] = "#{day_1['rain_chance']} chance of #{day_1['rain_range']} rain."
  end

  if day_2['rain_chance'] == '0%' or day_2['rain_range'] == '0 mm' then
    day_2['rain_forecast'] = 'No rain.'
  else
    begin
      day_2['rain_range'] = forecast.xpath("//area[@aac='#{bom_area}']/forecast-period[@index='#{day_2['index']}']/element[@type='precipitation_range']").first.children.first.text
    rescue
      day_2['rain_range'] = 'some'
    end
    day_2['rain_forecast'] = "#{day_2['rain_chance']} chance of #{day_2['rain_range']} rain."
  end

  send_event('forecast_1', day_1)
  send_event('forecast_2', day_2)

end
