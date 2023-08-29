local controlModifiers, p
local ini = init
function init() if ini and type(ini)=="function" then ini() end
  controlModifiers = mcontroller.controlModifiers
  p = {runningSuppressed=true,speedModifier=config.getParameter("percentage",0.7)}
end

function update(dt)
  controlModifiers(p)
end