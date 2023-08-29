function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  animator.setParticleEmitterOffsetRegion("energy", mcontroller.boundBox())
  entityId = entity.id()
  cooldown = 0
  storedDamage = 0
  currentTime = 0
  beepCooldown = 0
  baseCooldown = techConfig["rechargeTime"] or 5
  minimumTime = techConfig["minimumTime"] or 6
  beepStartTime = minimumTime/2
  minimumDamage = techConfig["minimumDamage"] or 100
  particleCap = techConfig["particleCap"] or minimumDamage
  beepDelay = techConfig["beepDelay"] or 1
  damageMultiplier = techConfig["damageMultiplier"] or 2
end

function update(dt)
  animator.setParticleEmitterEmissionRate("energy", math.min(storedDamage * (currentTime/2), particleCap))
--sb.setLogMap("^#ff0;sb_explosiveprotection","%s (%s)", storedDamage, math.floor(currentTime,2))
  local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
  queryDamageSince = nextStep
  for _, notification in ipairs(damageNotifications) do
    if notification.targetEntityId then
      local damage = notification.damageDealt
      if notification.sourceEntityId ~= notification.targetEntityId and cooldown <= 0 and damage > 0 then
	if storedDamage <= 0 then
	  animator.setParticleEmitterActive("energy", true)
	  animator.playSound("activate")
	end
	storedDamage = storedDamage + damage
      end
    end
  end

  if cooldown > 0 then
    cooldown = cooldown - dt
    if cooldown <= 0 then
      animator.setAnimationState("recharge", "recharge")
    end
  end

  if beepCooldown > 0 then beepCooldown = beepCooldown - dt end

  if storedDamage > 0 then
    currentTime = currentTime + dt
    if currentTime >= beepStartTime and beepCooldown <= 0 and currentTime < minimumTime then
      beepCooldown = beepDelay
      animator.playSound("beep")
    end
  end

  if storedDamage >= minimumDamage or currentTime >= minimumTime then
    animator.playSound("explode")
    world.spawnProjectile("mechexplosion", entity.position(), entityId, {0,0}, false, {power = storedDamage * damageMultiplier})
    cooldown = baseCooldown
    storedDamage = 0
    currentTime = 0
  end
end