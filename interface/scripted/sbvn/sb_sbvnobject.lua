local ini = init or function() end
local unini = uninit or function() end

function init() ini()
  storage = config.getParameter("scriptStorage", storage)
end

function uninit() unini()
  object.setConfigParameter("scriptStorage", storage)
end