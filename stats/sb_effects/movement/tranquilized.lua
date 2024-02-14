local ini = init
function init() if ini and type(ini)=="function" then ini() end
  tick = config.getParameter("tick",0.002)
  modifier = config.getParameter("start",1)
  min = config.getParameter("min",0.35)
  suppress = config.getParameter("suppressRunning",0.5)
end

function update(dt)
  mcontroller.controlModifiers({
  speedModifier=modifier,
  airJumpModifier=modifier,
  runningSuppressed=modifier<suppress
  })
  modifier = math.max(min,modifier-tick)
end