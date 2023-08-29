function swingInit()
  pi = -math.pi/2
  swing = 0.15
  firing = false
  activeItem.setArmAngle(pi)
end
function animateSwing(i) activeItem.setArmAngle(pi) script.setUpdateDelta(i or 0) end
function update(dt,f,s)
  if f == "primary" and not firing then firing = true end
  if firing then
    swing = math.max(0, swing - dt)
    activeItem.setArmAngle(pi * (swing / 0.15))
    if swing <= 0 then swingAction(dt,f,s) end
  end
end