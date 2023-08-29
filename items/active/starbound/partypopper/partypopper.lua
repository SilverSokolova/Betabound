require "/scripts/vec2.lua"

function init()
  emotes = config.getParameter("emotes")
  emoteChance = config.getParameter("emoteChance",2)
  consumeTimer = config.getParameter("consumeTimer",0.6)
  fireOffset = config.getParameter("fireOffset")
  recoil = 0
  recoilRate = 0
  active, firing = false, false
  storage.fireTimer = storage.fireTimer or 0
  animator.setPartTag("muzzleFlash", "variant", "1")
  updateAim()
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

  if active and storage.fireTimer <= 0 then
    consumeTimer = math.max(0, consumeTimer - dt)
    recoil = recoil + 0.1 -- aimAngle
    if animator.animationState("firing") == "off" then
      if math.random(emoteChance) == 1 then activeItem.emote(emotes[math.random(1,#emotes)]) end
      animator.setAnimationState("firing", "fire")
    end
    animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
    storage.fireTimer = config.getParameter("fireTime", 1.0)
  end
  active = false

  if firing then consumeTimer = math.max(0, consumeTimer - dt)
    if consumeTimer <= 0 then item.consume(1) consumeTimer = 1 firing = false end
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