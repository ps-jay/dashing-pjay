meter = 0
solar = 0
meter_update = false
solar_update = false

curr_use = 0

SCHEDULER.every '30s', :first_in => 0 do |job|

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
     new_solar_read = 123
     if new_solar_read != '' then
         solar = new_solar_read
         solar_update = true
     end
  end

  # Calculate consumption
  curr_use = meter + solar
  if curr_use < 200
    curr_use = 200  # Floor value
  end

  # Rounding
  meter = ("%0.01f" % (meter / 1000.0)).to_f()
  solar = ("%0.01f" % (solar / 1000.0)).to_f()
  curr_use = ("%0.01f" % (curr_use / 1000.0)).to_f()

  if solar_update then
    send_event('generating', { value: solar })
    solar_update = false
  end

  if meter_update or solar_update then
    send_event('consuming', { value: curr_use })
  end

  meter_update = false
  solar_update = false

end
