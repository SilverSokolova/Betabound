require "/scripts/vec2.lua"
require "/scripts/util.lua"

sb_staff = WeaponAbility:new()

function sb_staff:init()
  self.elementalType = self.elementalType or self.weapon.elementalType

  activeItem.setCursor("/cursors/reticle0.cursor")

  self.stances = config.getParameter("stances")
  self.weapon:setStance(self.stances.idle)

  self.weapon.onLeaveAbility = function()
    self:reset()
  end
end

function sb_staff:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if storage.sb_projectileId and not world.entityExists(storage.sb_projectileId) then
    storage.sb_projectileId = nil
  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function sb_staff:charge()
  self.weapon:setStance(self.stances.charge)

  animator.playSound(self.elementalType.."charge")
  animator.setAnimationState("charge", "charge")
  animator.setParticleEmitterActive(self.elementalType .. "charge", true)
  activeItem.setCursor("/cursors/charge2.cursor")

  local chargeTimer = self.stances.charge.duration
  while chargeTimer > 0 and self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    chargeTimer = chargeTimer - self.dt

    mcontroller.controlModifiers({runningSuppressed=true})

    coroutine.yield()
  end

  animator.stopAllSounds(self.elementalType.."charge")

  if chargeTimer <= 0 then
    self:setState(self.charged)
  else
    animator.playSound(self.elementalType.."discharge")
    self:setState(self.cooldown)
  end
end

function sb_staff:charged()
  self.weapon:setStance(self.stances.charged)

  animator.playSound(self.elementalType.."fullcharge")
  animator.playSound(self.elementalType.."chargedloop", -1)
  animator.setParticleEmitterActive(self.elementalType .. "charge", true)

  local targetValid
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    targetValid = self:targetValid(activeItem.ownerAimPosition())
    activeItem.setCursor(targetValid and "/cursors/chargeready.cursor" or "/cursors/chargeinvalid.cursor")

    mcontroller.controlModifiers({runningSuppressed=true})

    coroutine.yield()
  end

  animator.stopAllSounds(self.elementalType.."chargedloop")

  self:setState(self.discharge)
end

function sb_staff:discharge()
  self.weapon:setStance(self.stances.discharge)

  activeItem.setCursor("/cursors/reticle0.cursor")

  if self:targetValid(activeItem.ownerAimPosition()) and status.overConsumeResource("energy", self.energyCost) then
    animator.playSound(self.elementalType.."activate")
    self:createProjectile()
  else
    animator.playSound(self.elementalType.."discharge")
    self:setState(self.cooldown)
    return
  end

  util.wait(self.stances.discharge.duration, function(dt)

  end)

  self:setState(self.cooldown)
end

function sb_staff:cooldown()
  self.weapon:setStance(self.stances.cooldown)

  animator.setAnimationState("charge", "discharge")
  animator.setParticleEmitterActive(self.elementalType .. "charge", false)
  activeItem.setCursor("/cursors/reticle0.cursor")

  util.wait(self.stances.cooldown.duration, function()

  end)
end

function sb_staff:targetValid(aimPos)
  local focusPos = self:focusPosition()
  return world.magnitude(focusPos, aimPos) <= self.maxCastRange
      and not world.lineTileCollision(mcontroller.position(), focusPos)
      and not world.lineTileCollision(focusPos, aimPos)
end

function sb_staff:createProjectile()
  if storage.sb_projectileId then
    world.sendEntityMessage(storage.sb_projectileId, "kill")
  end

  local pParams = copy(self.projectileParameters)
  pParams.power = (pParams.baseDamage or 0) * config.getParameter("damageLevelMultiplier")
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  storage.sb_projectileId = world.spawnProjectile(
      self.projectileType,
      activeItem.ownerAimPosition(),
      activeItem.ownerEntityId(),
      {world.distance(activeItem.ownerAimPosition(),self:focusPosition())[1] > 0 and 1 or -1,0},
      false,
      pParams
    )
end

function sb_staff:focusPosition()
  local pos = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("stone", "focalPoint")))
  world.debugText("^shadow;focalPoint", pos, "green")
  return pos
end

function sb_staff:reset()
  self.weapon:setStance(self.stances.idle)
  animator.stopAllSounds(self.elementalType.."chargedloop")
  animator.stopAllSounds(self.elementalType.."fullcharge")
  animator.setAnimationState("charge", "idle")
  animator.setParticleEmitterActive(self.elementalType .. "charge", false)
  activeItem.setCursor("/cursors/reticle0.cursor")
end

function sb_staff:uninit(weaponUninit)
  self:reset()
end