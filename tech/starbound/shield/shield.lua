function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  shield = nil
  active = false
  beepCooldown = 0
  cooldownTimer = 0
  cooldown = techConfig["rechargeTime"] or 25
  maxShieldDuration = techConfig["shieldDuration"]
  shieldDuration = maxShieldDuration
  beepStart = techConfig["beepStart"] or -1
  beepDelay = techConfig["beepDelay"] or 1
  minDamage = techConfig["minDamage"]
  shieldHits = 1
end

function update(dt)
  if status.resourcePercentage("energy") > 0 then
    local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
    queryDamageSince = nextStep
    for _, notification in ipairs(damageNotifications) do
      if active then
	animator.playSound("block")
	status.overConsumeResource("energy", status.resourceMax("energy") / (8 - shieldHits))
	shieldHits = shieldHits * 2
	if shieldHits >= 8 then
	  shieldHits = 6
	end
	break
      end
      if notification.healthLost > minDamage and animator.animationState("shield") ~= "recharge" and notification.sourceEntityId ~= notification.targetEntityId and cooldownTimer <= 0 then
	status.overConsumeResource("energy", 50)
	activate()
      break
      end
    end
  else
    deactivate()
  end

  if active then
    status.setResourcePercentage("sb_shieldStaminaT",shieldDuration/maxShieldDuration)
    if shieldDuration <= 0 then deactivate() end
    if shieldDuration < beepStart and beepCooldown <= 0 then
      beepCooldown = beepDelay
      animator.playSound("beep")
    end
  end

  if cooldownTimer > 0 then
    cooldownTimer = cooldownTimer - dt
    if cooldownTimer <= 0 then
      animator.setAnimationState("shield", "recharge")
    end
  end
  if shieldDuration > 0 then shieldDuration = shieldDuration - dt end
  if beepCooldown > 0 then beepCooldown = beepCooldown - dt end
end

function activate()
  animator.playSound("activate")
  shieldDuration = maxShieldDuration
  status.setResourcePercentage("sb_shieldStaminaT",1)
  animator.setAnimationState("shield", "on")
  shieldHits = 1
  active = true
end


function deactivate()
  if active then animator.playSound("activate") end
  active = false
  cooldownTimer = cooldown
  animator.setAnimationState("shield", "off")
  status.setResourcePercentage("sb_shieldStaminaT",0)
end

function uninit() deactivate() end