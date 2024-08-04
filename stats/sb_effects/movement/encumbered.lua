local controlModifiers, p
local originalInit = init
function init() if ini and type(ini)=="function" then originalInit() end
  controlModifiers = mcontroller.controlModifiers
  p = {runningSuppressed=true,speedModifier=config.getParameter("percentage",0.7)}
end

function update(dt)
  controlModifiers(p)
end