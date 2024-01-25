function init()
  recoil = 0
  recoilRate = 0
  fireOffset = config.getParameter("fireOffset",0)
  updateAim()
  active = false
  storage.fireTimer = storage.fireTimer or 0
end

function update(dt, fireMode, shiftHeld)
  updateAim()
  storage.fireTimer = math.max(storage.fireTimer - dt, 0)
  if active then
    recoilRate = 0
  else
    recoilRate = math.max(1, recoilRate + (10 * dt))
  end
  recoil = math.max(recoil - dt * recoilRate, 0)

  if active and not storage.firing and storage.fireTimer <= 0 then
    recoil = math.pi/2 - aimAngle
    activeItem.setArmAngle(math.pi/2)
    if animator.animationState("firing") == "off" then
      animator.setAnimationState("firing", "fire")
    end
    storage.fireTimer = config.getParameter("fireTime", 1)
    storage.firing = true

  end

  active = false

  if storage.firing and animator.animationState("firing") == "off" then
    item.consume(1)
    local items = config.getParameter("items")
    if player then
      if items then
        if type(items) == "string" then items = {items} end
        for i = 1, #items do
          player.giveItem(items[i])
        end
      end
    end
    storage.firing = false
    storage.fireTimer = 0
    return
  end
end

function activate(fireMode, shiftHeld)
  if not storage.firing then
    active = true
  end
end

function updateAim()
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(fireOffset, activeItem.ownerAimPosition())
  aimAngle = aimAngle + recoil
  activeItem.setArmAngle(aimAngle)
  activeItem.setFacingDirection(aimDirection)
end