require "/scripts/util.lua"
require "/scripts/interp.lua"
--require "/items/active/weapons/ranged/gunfire.lua" --required to keep Marked Shot from breaking. Also MS's animation doesn't show since animationScripts on both abilities

sb_AmmoGunFire = WeaponAbility:new()

function sb_AmmoGunFire:init()
  self.weapon:setStance(self.stances.idle)
  self.cooldownTimer = self.fireTime
  self.energyProjectileType = config.getParameter("projectileType", "standardbullet")
  self.usingAmmo = false
  if not player then
    activeItem.setScriptedAnimationParameter("npc", true)
    sb_AmmoGunFire["updateAmmo"] = function() end
    sb_AmmoGunFire["consumeAmmo"] = function() return false end
    self.projectileType = self.energyProjectileType
  end
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function sb_AmmoGunFire:updateAmmo(shiftHeld)
  local h = activeItem.hand()=="alt" and "primary" or "alt"
  local a = world.entityHandItem(activeItem.ownerEntityId(),h)
  activeItem.setScriptedAnimationParameter("hand",a and root.itemHasTag(a,"sb_info") and h=="alt" and 2 or 3)
  --and how does this interact with two-handed items? just 'primary'?
  --not ideal to have this in update, but switching from an infoitem to two guns shows ammo counter twice
  projectileType = sb_AmmoGunFire:checkAmmo()
  if shiftHeld and projectileType then
    self.projectileType = projectileType.parameters.projectileType or "bullet-1"
    self.power = root.projectileConfig(self.projectileType).sb_power or 0
  else
    self.power = 0
  end
  ammoCount = player.hasCountOfItem("sb_ammo")
  self.usingAmmo = shiftHeld and ammoCount > 0
  activeItem.setScriptedAnimationParameter("ammo",self.usingAmmo and ammoCount or 0)
  activeItem.setScriptedAnimationParameter("name",self.projectileType)
end

function sb_AmmoGunFire:checkAmmo()
  local hands = {player.primaryHandItem(),player.altHandItem()}
  for i = 1, 2 do
    if hands[i] and hands[i].name == "sb_ammo" then
      return hands[i]
    end
  end
  return player.getItemWithParameter("itemName","sb_ammo")
end

function sb_AmmoGunFire:consumeAmmo()
  return player.consumeItem({"sb_ammo",1,{projectileType=self.projectileType}},false,true)
end

function sb_AmmoGunFire:canShoot()
  return self.usingAmmo and ammoCount > 0 and self:consumeAmmo() or status.overConsumeResource("energy", self:energyPerShot())
end

function sb_AmmoGunFire:update(dt, fireMode, shiftHeld)
  self:updateAmmo(not shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

    if self.fireType == "auto" and self:canShoot() then
      self:setState(self.auto)
    elseif self.fireType == "burst" then
      self:setState(self.burst)
    end
  end
end

function sb_AmmoGunFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.fireTime
  self:setState(self.cooldown)
end

function sb_AmmoGunFire:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 and self:canShoot() do
    self:fireProjectile()
    self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    util.wait(self.burstTime)
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

function sb_AmmoGunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function sb_AmmoGunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end

function sb_AmmoGunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  projectileType = self.usingAmmo and self.projectileType or self.energyProjectileType
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot() * (self.usingAmmo and 1 or (self.energyDamageMultiplier or 0.8))
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = (util.randomInRange(params.speed) or 0) + (root.projectileConfig(projectileType).speed or 0)


  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

function sb_AmmoGunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function sb_AmmoGunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function sb_AmmoGunFire:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function sb_AmmoGunFire:damagePerShot()
  return self.power + (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function sb_AmmoGunFire:uninit()
end