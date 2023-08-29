function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  effect = techConfig["effect"] or "sb_health"
  minimumDamage = techConfig["minimumDamage"] or 1
  percentage = techConfig["percentage"] or 1
end

function update(dt)
  local damageNotificationsOutgoing, nextStep = status.inflictedDamageSince(queryDamageSince)
  queryDamageSince = nextStep
  for _, notification in ipairs(damageNotificationsOutgoing) do
    if notification.targetEntityId then
      if notification.sourceEntityId ~= notification.targetEntityId and (notification.healthLost > minimumDamage) and (notification.healthLost/percentage) > 0 then
	status.addEphemeralEffect(effect,notification.healthLost/percentage)
      end
    end
  end
end