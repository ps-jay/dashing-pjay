require 'net/http'
require 'uri'

meter = 0
solar = 0
meter_update = false
solar_update = false

curr_use = 0

SCHEDULER.every '55s', :first_in => 0 do |job|

  # Get metered demand
  begin
    new_meter_read = `python jobs/rain_eagle.py`
    if new_meter_read != '' then
      meter = new_meter_read.to_i
      meter_update = true
    end
  end

  # Get solar generation
  begin
    uri = URI.parse('http://10.10.8.42/home')
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.request(Net::HTTP::Get.new(uri.request_uri))

    generate_start = /<td>Currently generating<\/td>/ =~ resp.body
    generate_to_eof = resp.body[generate_start..-1]
    generate_cell = /<td>\s*(\d|\.)+\sk?W\s*<\/td>/ =~ generate_to_eof
    generate_end = /\d\s/ =~ generate_to_eof[(generate_cell+4)..-1]
    new_solar_read = generate_to_eof[(generate_kw+4),(generate_end+1)].strip
    # kW -> W
    if /kW/ =~ generate_to_eof[(generate_cell+4),(generate_end+4)] then
      new_solar_read = new_solar_read * 1000
    end

    panels_start = /<td>Number of Microinverters<\/td>/ =~ resp.body
    panels_to_eof = resp.body[panels_start..-1]
    panels_count = /<td>\d+<\/td>/ =~ panels_to_eof
    panels_end = /<\/td>/ =~ panels_to_eof[(panels_count+4)..-1]
    panels = panels_to_eof[(panels_count+4),panels_end].to_i()

    online_start = /<td>Number of Microinverters Online<\/td>/ =~ resp.body
    online_to_eof = resp.body[online_start..-1]
    online_count = /<td>\d+<\/td>/ =~ online_to_eof
    online_end = /<\/td>/ =~ online_to_eof[(online_count+4)..-1]
    online = online_to_eof[(online_count+4),online_end].to_i()

    if new_solar_read != '' then
      solar = new_solar_read.to_f() * 1000
      solar_update = true
    end
  end

  # Calculate consumption
  curr_use = meter + solar
  if curr_use < 100
    curr_use = 100  # Floor value
  end

  # Rounding
  solar_kw = ("%0.01f" % (solar / 1000.0)).to_f()
  curr_kw = ("%0.01f" % (curr_use / 1000.0)).to_f()

  if solar_update then
    send_event('generating', { value: solar_kw, panels: panels, online: online })
    solar_update = false
  end

  if meter_update or solar_update then
    send_event('consuming', { value: curr_kw })
  end

  meter_update = false
  solar_update = false

end
