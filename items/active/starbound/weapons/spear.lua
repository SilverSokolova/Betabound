require "/items/active/weapons/weapon.lua"
require "/items/active/starbound/weapons/meleeslash2.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
Spear = MeleeSlash:new()

function Spear:init()
  MeleeSlash.init(self)
  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
  self.projectilePower = self.damageConfig.baseDamage * config.getParameter("damageLevelMultiplier",1) * config.getParameter("projectileDamageMultiplier", 0.6)
end

function Spear:fire()
  projectileFire(self)
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  animator.setAnimationState("swoosh", "fire")
  animator.playSound(self.fireSound or (self.elementalType or self.weapon.elementalType or "physical").."fire")
  animator.burstParticleEmitter((self.elementalType or self.weapon.elementalType) .. "swoosh")

  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
  end)

  self.cooldownTimer = self.fireTime - self.stances.windup.duration - self.stances.fire.duration

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
