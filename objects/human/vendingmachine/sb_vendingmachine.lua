--local originalInit = init or function() end function init() originalInit() object.setInteractive = function() end end
local originalUpdate = update or function() end
function update(...) originalUpdate(...)
  object.setConfigParameter("treasurePools",{"empty"})
  storage = {}
  object.setInteractive(animator.animationState("light") == "on" or false)
end