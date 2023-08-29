require "/items/active/weapons/weapon.lua"
require "/items/active/starbound/weapons/meleeslash2.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
Spear = MeleeSlash:new()

function Spear:init()
  MeleeSlash.init(self)
  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
  self.projectilePower = self.damageConfig.baseDamage * config.getParameter("damageLevelMultiplier",1) * config.getParameter("projectileDamageMultiplier",0.6)
end

function MeleeSlash:fire()
  if self.projectileType then
  --local position = vec2.add(mcontroller.position(), {projectileOffset[1] * mcontroller.facingDirection(), (-1.5 + projectileOffset[2])})
    local params = {
      powerMultiplier = activeItem.ownerPowerMultiplier(),
      power = self.projectilePower
    }
    self.inaccuracy=self.inaccuracy or 0
    local position = vec2.add(mcontroller.position(), activeItem.handPosition({-3,8}))--animator.partPoint("chargeSwoosh", "projectileSource")))
      local aim = self.weapon.aimAngle + util.randomInRange({-self.inaccuracy, self.inaccuracy})
    world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false,params)
  end
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  animator.setAnimationState("swoosh", "fire")
  animator.playSound(self.fireSound or (self.elementalType or self.weapon.elementalType or "physical").."fire")
  animator.burstParticleEmitter((self.elementalType or self.weapon.elementalType) .. "swoosh")

  util.wait(self.stances.fire.duration, function()
    if self.projectileType ~= "sb_swordblank" then
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime) end
  end)

  self.cooldownTimer = self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function Spear:fire()
  MeleeSlash.fire(self)

  if self.fireMode == "primary" and self.allowHold ~= false then
    self:setState(self.hold)
  end
end

function Spear:hold()
  self.weapon:setStance(self.stances.hold)
  self.weapon:updateAim()

  while self.fireMode == "primary" do
    local damageArea = partDamageArea("blade")
    self.weapon:setDamage(self.holdDamageConfig, damageArea)
    coroutine.yield()
  end

  if cooldownTime then self.cooldownTimer = self:cooldownTime() end
end
