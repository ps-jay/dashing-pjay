require 'net/http'
require 'json'

# Homeassistant API Key
ha_api_key = ENV['HAKEY']

curr_meter_time = 0
curr_meter_read = 0

curr_solar_time = 0
curr_solar_read = 0

curr_use = 0

demand = URI.parse('http://10.10.1.5:8123/api/states/sensor.current_demand')
generation = URI.parse('http://10.10.1.5:8123/api/states/sensor.inverter_instant_power')

headers = {
  'Authorization' => 'Bearer ' + ha_api_key,
  'Content-Type' => 'application/json',
}

SCHEDULER.every '15s', :first_in => 0 do |job|

  last_meter_time = curr_meter_time
  last_meter_read = curr_meter_read

  last_solar_time = curr_solar_time
  last_solar_read = curr_solar_read

  last_use = curr_use
  time_change = false

  # Get metered demand
  http = Net::HTTP.new(demand.host, demand.port)
  resp = http.get(demand.path, headers)
  dem = JSON.parse(resp.body)
  curr_meter_time = dem['last_updated']
  curr_meter_read = dem['state'].to_f

  # Get solar generation
  http = Net::HTTP.new(generation.host, generation.port)
  resp = http.get(generation.path, headers)
  gen = JSON.parse(resp.body)
  curr_solar_time = gen['last_updated']
  curr_solar_read = gen['state'].to_f / 1000.0

  # Calculate consumption
  curr_use = curr_meter_read + curr_solar_read
  if curr_use < 0.1
    curr_use = 0.1  # Floor value
  end

  # Rounding
  curr_meter_read = ("%0.01f" % curr_meter_read).to_f()
  curr_solar_read = ("%0.01f" % curr_solar_read).to_f()
  curr_use = ("%0.01f" % curr_use).to_f()

  if curr_meter_time != last_meter_time
    if curr_meter_read < 0
      title = "Selling"
      value = curr_meter_read * -1
    else
      title = "Buying"
      value = curr_meter_read
    end
    send_event('griddemand', { value: value, title: title })
    time_change = true
  end

  if curr_solar_time != last_solar_time
    send_event('generating', { value: curr_solar_read })
    time_change = true
  end

  if time_change
    send_event('consuming', { value: curr_use })
  end

end
