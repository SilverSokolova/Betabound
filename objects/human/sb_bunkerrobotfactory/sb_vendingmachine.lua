--local ini = init or function() end function init() ini() object.setInteractive = function() end end
local updat = update or function() end function update(...) updat(...) object.setConfigParameter("treasurePools",{"empty"}) storage = {} object.setInteractive(animator.animationState("light") == "on" or false) end
