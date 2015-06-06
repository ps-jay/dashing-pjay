class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    day = today.getDay()
    day = switch
      when day == 0 then "Sunday"
      when day == 1 then "Monday"
      when day == 2 then "Tuesday"
      when day == 3 then "Wednesday"
      when day == 4 then "Thursday"
      when day == 5 then "Friday"
      when day == 6 then "Saturday"

    month = today.getMonth()
    month = switch
      when month == 0 then "January"
      when month == 1 then "February"
      when month == 2 then "March"
      when month == 3 then "April"
      when month == 4 then "May"
      when month == 5 then "June"
      when month == 6 then "July"
      when month == 7 then "August"
      when month == 8 then "September"
      when month == 9 then "October"
      when month == 10 then "November"
      when month == 11 then "December"

    h = today.getHours()
    m = today.getMinutes()
    s = today.getSeconds()
    m = @formatTime(m)
    s = @formatTime(s)
    d = @formatDate(today.getDate())
    @set('time', h + ":" + m)
    @set('date', day + ", " + d + " " + month)

  formatDate: (i) ->
    if (i == 1 or i == 21 or i == 31) then i + "st"
    else if (i == 2 or i == 22) then i + "nd"
    else if (i == 3 or i == 23) then i + "rd"
    else i + "th"

  formatTime: (i) ->
    if i < 10 then "0" + i else i
