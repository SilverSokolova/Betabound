function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  effect = techConfig["effect"] or "sb_energy"
  minimumDamage = techConfig["minimumDamage"] or 1
  multiplier = techConfig["multiplier"] or 1
end

function update(dt)
  local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
  queryDamageSince = nextStep
  for _, notification in ipairs(damageNotifications) do
    if notification.targetEntityId then
      if notification.sourceEntityId ~= notification.targetEntityId and (notification.healthLost > minimumDamage) and (notification.healthLost*multiplier) > 0 then
        status.addEphemeralEffect(effect,notification.healthLost*multiplier)
      end
    end
  end
end