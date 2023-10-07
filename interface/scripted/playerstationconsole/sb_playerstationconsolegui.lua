local sb_init = init or function() end
local sb_update = update or function() end

function init() sb_init()
  widget.setPosition("sb_lblGravity", {widget.getPosition("sb_lblGravity")[1], widget.getPosition("lblGravity")[2]})
end

function update(...) sb_update(...)
  widget.setText("sb_lblGravity", widget.getSliderValue("sldGravity"))
end