--meleeslash without combo
require "/items/active/weapons/weapon.lua"
require "/items/active/starbound/weapons/projectile.lua"

MeleeSlash = WeaponAbility:new()

function MeleeSlash:init()
  self.damageConfig = self.damageConfig or {}
  self.damageConfig.baseDamage = self.baseDps * self.fireTime
  self.projectilePower = self.damageConfig.baseDamage * config.getParameter("damageLevelMultiplier",1) * config.getParameter("projectileDamageMultiplier",0.6)
  self.energyUsage = self.energyUsage or 0
  self.inaccuracy = self.inaccuracy or 0

  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = self.fireTime - self.stances.windup.duration - self.stances.fire.duration

  projectileInit(self, config.getParameter("primaryAbility"))
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

-- Ticks on every update regardless if this is the active ability
function MeleeSlash:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if not self.weapon.currentAbility and self.fireMode == (self.activatingFireMode or self.abilitySlot) and self.cooldownTimer == 0 and (self.energyUsage == 0 or not status.resourceLocked("energy")) then
    self:setState(self.windup)
  end
end

-- State: windup
function MeleeSlash:windup()
  self.weapon:setStance(self.stances.windup)

  if self.stances.windup.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
    util.wait(self.stances.windup.duration)
  end

  if self.energyUsage then
    status.overConsumeResource("energy", self.energyUsage)
  end

  if self.stances.preslash then
    self:setState(self.preslash)
  else
    self:setState(self.fire)
  end
end

-- State: preslash
-- brief frame in between windup and fire
function MeleeSlash:preslash()
  self.weapon:setStance(self.stances.preslash)
  self.weapon:updateAim()

  util.wait(self.stances.preslash.duration)

  self:setState(self.fire)
end

-- State: fire
function MeleeSlash:fire()
  projectileFire(self)
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  animator.setAnimationState("swoosh", "fire")
  animator.playSound(self.fireSound or (self.elementalType or self.weapon.elementalType or "physical").."fire")
  if animator.hasSound("extraFire") then animator.playSound("extraFire") end
  animator.burstParticleEmitter((self.elementalType or self.weapon.elementalType or "physical") .. "swoosh")

  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
  end)

  self.cooldownTimer = self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function MeleeSlash:uninit()
  self.weapon:setDamage()
end
