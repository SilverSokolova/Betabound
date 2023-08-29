require "/scripts/util.lua"
require "/scripts/status.lua"
require "/items/active/weapons/weapon.lua"

Parry = WeaponAbility:new()

function Parry:init()
  self.cooldownTimer = 0
end

function Parry:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
    and not npc
    and fireMode == (config.getParameter("twoHanded",false) and "alt" or "primary")
    and self.cooldownTimer == 0
    and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.parry)
  end
end

function Parry:parry()
  if not status.resourcePositive("sb_shieldStamina"..(activeItem.hand() == "alt" and "R" or "L")) then return end
  self.weapon:setStance(self.stances.parry)
  self.weapon:updateAim()
  status.setPersistentEffects("sb_broadswordParry"..(activeItem.hand() == "alt" and "R" or "L"), {{stat = "sb_shieldHealth"..(activeItem.hand() == "alt" and "R" or "L"), amount = config.getParameter("shieldHealth",self.shieldHealth)}})

  local blockPoly = animator.partPoly("parryShield", "shieldPoly")
  activeItem.setItemShieldPolys({blockPoly})
  if true then
    local knockbackDamageSource = {
      poly = blockPoly,
      damage = 0,
      damageType = "Knockback",
      sourceEntity = activeItem.ownerEntityId(),
      team = activeItem.ownerTeam(),
      knockback = 15,
      rayCheck = true,
      damageRepeatTimeout = 0.25
    }
    activeItem.setItemDamageSources({knockbackDamageSource})
  end

  animator.setAnimationState("parryShield", "active")
  animator.playSound("guard")

  message.setHandler("sb_applyShieldDamage"..(activeItem.hand() == "alt" and "R" or "L"), function(_,hand)
	animator.burstParticleEmitter("parryParticle")
        animator.setAnimationState("parryShield", "block")
        if not status.resourcePositive("sb_shieldStamina"..(activeItem.hand() == "alt" and "R" or "L")) then
	  animator.burstParticleEmitter("guardbroken")
          animator.playSound("break")
	else
          animator.playSound("parry")
	end
  end)
  util.wait(self.parryTime, function(dt)
    if not status.resourcePositive("sb_shieldStamina"..(activeItem.hand() == "alt" and "R" or "L")) then return true end
  end)

  self.cooldownTimer = self.cooldownTime
  activeItem.setItemShieldPolys({})
  activeItem.setItemDamageSources({})
end

function Parry:reset()
  self.weapon:setStance(self.stances.idle)
  animator.setAnimationState("parryShield", "inactive")
  status.clearPersistentEffects("sb_broadswordParry"..(activeItem.hand() == "alt" and "R" or "L"))
  activeItem.setItemShieldPolys({})
  activeItem.setItemDamageSources({})
end

function Parry:uninit()
  self:reset()
end
