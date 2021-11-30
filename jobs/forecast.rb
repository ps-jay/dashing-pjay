require 'net/http'
require 'json'
require 'time'

# Homeassistant API Key
ha_api_key = ENV['HAKEY']

homeassistant = URI.parse('http://10.10.1.5:8123')

temp_min = '/api/states/sensor.blackburn_temp_min_'
temp_max = '/api/states/sensor.blackburn_temp_max_'
rain_chance = '/api/states/sensor.blackburn_rain_chance_'
rain_range = '/api/states/sensor.blackburn_rain_amount_range_'
precis = '/api/states/sensor.blackburn_short_text_'

headers = {
  'Authorization' => 'Bearer ' + ha_api_key,
  'Content-Type' => 'application/json',
}

SCHEDULER.every '60m', :first_in => 0 do |job|
  if Time.now.hour < 16 then
    # It's before 4pm - show today and tomorrow
    day_1 = {
      'name' => 'Today',
      'index' => 0,
    }
    day_2 = {
      'name' => 'Tomorrow',
      'index' => 1,
    }
  else
    # It's after 4pm - show tomorrow and the next day
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

  min_day_1 = URI.parse(temp_min + day_1['index'].to_s)
  max_day_1 = URI.parse(temp_max + day_1['index'].to_s)
  chance_day_1 = URI.parse(rain_chance + day_1['index'].to_s)
  range_day_1 = URI.parse(rain_range + day_1['index'].to_s)
  precis_day_1 = URI.parse(precis + day_1['index'].to_s)

  min_day_2 = URI.parse(temp_min + day_2['index'].to_s)
  max_day_2 = URI.parse(temp_max + day_2['index'].to_s)
  chance_day_2 = URI.parse(rain_chance + day_2['index'].to_s)
  range_day_2 = URI.parse(rain_range + day_2['index'].to_s)
  precis_day_2 = URI.parse(precis + day_2['index'].to_s)

  http = Net::HTTP.new(homeassistant.host, homeassistant.port)

  day_1['min'] = JSON.parse(http.get(min_day_1.path, headers).body)['state']
  day_1['max'] = JSON.parse(http.get(max_day_1.path, headers).body)['state']
  day_1['rain_chance'] = JSON.parse(http.get(chance_day_1.path, headers).body)['state'] + '%'
  day_1['rain_range'] = JSON.parse(http.get(range_day_1.path, headers).body)['state'] + ' mm'
  day_1['precis'] = JSON.parse(http.get(precis_day_1.path, headers).body)['state']

  day_2['min'] = JSON.parse(http.get(min_day_2.path, headers).body)['state']
  day_2['max'] = JSON.parse(http.get(max_day_2.path, headers).body)['state']
  day_2['rain_chance'] = JSON.parse(http.get(chance_day_2.path, headers).body)['state'] + '%'
  day_2['rain_range'] = JSON.parse(http.get(range_day_2.path, headers).body)['state'] + ' mm'
  day_2['precis'] = JSON.parse(http.get(precis_day_2.path, headers).body)['state']

  # Adjust rain forecast to avoid "0% change of 0mm of rain" and the like...
  if day_1['rain_chance'] == '0%' or day_1['rain_range'] == '0 mm' then
    day_1['rain_forecast'] = 'No rain.'
  else
    day_1['rain_forecast'] = "#{day_1['rain_chance']} chance of #{day_1['rain_range']} rain."
  end

  if day_2['rain_chance'] == '0%' or day_2['rain_range'] == '0 mm' then
    day_2['rain_forecast'] = 'No rain.'
  else
    day_2['rain_forecast'] = "#{day_2['rain_chance']} chance of #{day_2['rain_range']} rain."
  end

  send_event('forecast_1', day_1)
  send_event('forecast_2', day_2)

end
