--WONTFIX: You can reuse them by dropping them before they're consumed

function init()
  emotes = config.getParameter("emotes")
  emoteChance = config.getParameter("emoteChance", 2)
  storage.consumeTimer = storage.consumeTimer or config.getParameter("consumeTimer", 0.6)
  fireOffset = config.getParameter("fireOffset")
  baseFireTime = config.getParameter("fireTime", 1)
  recoil = 0
  recoilRate = 0
  active, firing = false, firing or false
  storage.fireTimer = storage.fireTimer or 0
  animator.setPartTag("muzzleFlash", "variant", "1")
  updateAim()
end

function update(dt, fireMode, shiftHeld)
  updateAim()
  storage.fireTimer = math.max(storage.fireTimer - dt, 0)

  recoilRate = active and 0 or math.max(1, recoilRate + (10 * dt))
  recoil = math.max(recoil - dt * recoilRate, 0)

  if active and storage.fireTimer <= 0 then
    storage.consumeTimer = math.max(0, storage.consumeTimer - dt)
    recoil = recoil + 0.1 -- aimAngle
    if animator.animationState("firing") == "off" then
      if math.random(emoteChance) == 1 then
        activeItem.emote(emotes[math.random(#emotes)])
      end
      animator.setAnimationState("firing", "fire")
    end
    animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
    storage.fireTimer = baseFireTime
  end
  active = false

  if firing then
    storage.consumeTimer = math.max(0, storage.consumeTimer - dt)
    if storage.consumeTimer <= 0 then
      item.consume(1)
      storage.consumeTimer = 1
      firing = false
    end
  end
end

function activate()
  active, firing = true, true
end

function updateAim()
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(fireOffset[2], activeItem.ownerAimPosition())
  aimAngle = aimAngle + recoil
  activeItem.setArmAngle(aimAngle)
  activeItem.setFacingDirection(aimDirection)
end