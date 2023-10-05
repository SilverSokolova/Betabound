function swingInit()
  activeItem.setArmAngle(-math.pi / 2)
  swingStart = config.getParameter("swingStart", -60) * math.pi / 180
  swingFinish = config.getParameter("swingFinish", 40) * math.pi / 180
  currentSwing = swingStart
  currentAngle = -swingStart
  useTime = config.getParameter("useTime", 0.1)
  autoFire = config.getParameter("autoFire")
end

function update(dt, fireMode, shiftHeld)
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)

  if not useTimer and fireMode == "primary" and not justUsed then
    useTimer = useTime
    justUsed = autoFire and true or false
  end

  if useTimer then
    useTimer = useTimer - dt
    currentAngle = ((currentSwing - swingFinish) * useTimer / 0.15 * 1)/2.4
    activeItem.setArmAngle(currentAngle)

    if currentAngle >= swingFinish then
      swingAction(dt, fireMode, shiftHeld)
      activeItem.setArmAngle(-math.pi / 2)
      currentAngle = -swingStart
      currentSwing = swingStart
      useTimer = nil
    end
  end
  justUsed = fireMode == "primary" and not autoFire
end