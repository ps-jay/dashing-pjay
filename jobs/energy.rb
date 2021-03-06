require 'sqlite3'

curr_meter_time = 0
curr_meter_read = 0

curr_solar_time = 0
curr_solar_read = 0

curr_use = 0

SCHEDULER.every '15s', :first_in => 0 do |job|

  last_meter_time = curr_meter_time
  last_meter_read = curr_meter_read

  last_solar_time = curr_solar_time
  last_solar_read = curr_solar_read

  last_use = curr_use
  time_change = false

  # Get metered demand
  begin
    db = SQLite3::Database.open "/energy-data/raven.sqlite"
    db.results_as_hash = true
    stm = db.prepare "SELECT * FROM demand ORDER BY timestamp DESC LIMIT 1"
    rs = stm.execute
    rs.each do |row|
      curr_meter_time = row['timestamp']
      curr_meter_read = row['watts'] / 1000.0
    end
  ensure
    stm.close if stm
    db.close if db
  end

  # Get solar generation
  begin
    db = SQLite3::Database.open "/energy-data/solar.sqlite"
    db.results_as_hash = true
    stm = db.prepare "SELECT * FROM system ORDER BY timestamp DESC LIMIT 1"
    rs = stm.execute
    rs.each do |row|
      curr_solar_time = row['timestamp']
      curr_solar_read = row['pout_W'] / 1000.0
    end
  ensure
    stm.close if stm
    db.close if db
  end

  # Calculate consumption
  curr_use = curr_meter_read + curr_solar_read
  if curr_use < 0.3
    curr_use = 0.3  # Floor value
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
