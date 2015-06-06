class Dashing.Demand extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super

  onData: (data) ->
    node = $(@node)
    value = parseFloat data.value
    cool = parseFloat node.data "cool"
    warm = parseFloat node.data "warm"
    level = switch
      when value < cool then 0
      when value >= warm then 1
  
    backgroundClass = "demand#{level}"
    lastClass = @get "lastClass"
    node.toggleClass "#{lastClass} #{backgroundClass}"
    @set "lastClass", backgroundClass
