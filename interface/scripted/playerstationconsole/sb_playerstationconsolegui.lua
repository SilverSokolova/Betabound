local originalInit = init or function() end
local originalUpdate = update or function() end

function init() originalInit()
  widget.setPosition("sb_lblGravity", {widget.getPosition("sb_lblGravity")[1], widget.getPosition("lblGravity")[2]})
end

function update(...) originalUpdate(...)
  widget.setText("sb_lblGravity", widget.getSliderValue("sldGravity"))
end