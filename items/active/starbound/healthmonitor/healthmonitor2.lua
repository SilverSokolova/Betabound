function init()
  activeItem.setHoldingItem(false)
  local a = activeItem.hand()
  if a then activeItem.setScriptedAnimationParameter("hand", a) end
  activeItem.setScriptedAnimationParameter("colors",config.getParameter("colors"))
  r = config.getParameter("resources")
end

function update()
  local cr, mr = {}, {}
  for i = 1, #r do
    cr[i] = status.resource(r[i])
    mr[i] = status.resourceMax(r[i])
  end
  activeItem.setScriptedAnimationParameter("c",cr)
  activeItem.setScriptedAnimationParameter("m",mr)
end