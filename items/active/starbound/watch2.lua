function init()
  activeItem.setHoldingItem(false)
  local a = activeItem.hand()
  if a then activeItem.setScriptedAnimationParameter("hand", a) end
end