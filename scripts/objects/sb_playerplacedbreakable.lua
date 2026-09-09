local originalInit = init or function() end

function init(); originalInit()
  if config.getParameter("owner") then
    local parameters = {"smashDropPool", "breakDropPool"}
    for i = 1, #parameters do
      local value = config.getParameter(parameters[i])
      if value and value ~= "empty" then
        object.setConfigParameter(parameters[i], "empty")
      end
    end
  end
end