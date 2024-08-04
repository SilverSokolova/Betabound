local originalInit = init or function() end
local originalUninit = uninit or function() end

function init() originalInit()
  storage = config.getParameter("scriptStorage", storage)
end

function uninit() originalUninit()
  object.setConfigParameter("scriptStorage", storage)
end