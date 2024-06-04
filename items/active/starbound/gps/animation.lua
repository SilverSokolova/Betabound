function update(dt)
  localAnimator.clearDrawables()
  local position = activeItemAnimation.ownerPosition()
  local text = tostring(math.floor(position[1]))..","..tostring(math.floor(position[2]))
  textPositionOffset = addText(text, position)
end