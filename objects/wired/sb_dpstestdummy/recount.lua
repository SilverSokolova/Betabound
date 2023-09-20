function init()
  maxHealth = config.getParameter("health")
  dialogue = config.getParameter("dialogue")
  autoResetTime = config.getParameter("autoResetTime", 7)
  autoResetTimer = 0
  wasHit = false
  firstHit = false
  lastMeterTimer = 0
  lastDps = 0
  reset()
  object.setInteractive(true)
end

function update(dt)
  local currentHealth = object.health()

  autoResetTimer = math.max(0, autoResetTimer - dt)
  if autoResetTimer == 0 then
    reset()
  end

  if currentHealth < maxHealth then
    meterActive = true
    autoResetTimer = autoResetTime
    wasHit = true
  else
    wasHit = false
  end

  if meterActive then
    meterTimer = meterTimer + dt
    totalDamage = totalDamage + (maxHealth - currentHealth)
    object.setHealth(maxHealth)
  end

  local dps = meterTimer > 0 and (totalDamage / (not firstHit and 1 or meterTimer)) or 0
  if wasHit then
    firstHit = true
    lastMeterTimer = meterTimer
    lastDps = dps
  end

  if meterTimer ~= 0 then
    object.say(string.format(dialogue, totalDamage, lastMeterTimer, lastDps))
  end
end

function onInteraction(args)
  if meterActive then
    object.say(string.format(dialogue, 0, 0, 0))
    reset()
  else
    object.smash()
  end
end

function reset()
  meterActive = false
  firstHit = false
  wasHit = false
  meterTimer = 0
  totalDamage = 0
  lastMeterTimer = 0
  lastDps = 0
  object.setHealth(maxHealth)
end