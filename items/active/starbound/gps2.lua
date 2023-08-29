function init()
  activeItem.setHoldingItem(false)
  local a = activeItem.hand()
  if a then activeItem.setScriptedAnimationParameter("hand", a) end
end

function update()
  activeItem.setScriptedAnimationParameter("c",mcontroller.position())
end