class Dashing.Hotness extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super

  onData: (data) ->
    node = $(@node)
    value = parseFloat data.value
    cool = parseFloat node.data "cool"
    warm = parseFloat node.data "warm"
    interval = ((warm - cool) / 3)
    int1 = (cool + (interval * 1))
    int2 = (cool + (interval * 2))
    level = switch
      when value < cool then 0
      when value < int1 then 1
      when value < int2 then 2
      when value < warm then 3
      when value >= warm then 4
  
    backgroundClass = "hotness#{level}"
    lastClass = @get "lastClass"
    node.toggleClass "#{lastClass} #{backgroundClass}"
    @set "lastClass", backgroundClass
