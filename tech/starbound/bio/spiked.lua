function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  minimumDamage = techConfig["minimumDamage"] or 1
  percentage = techConfig["percentage"] or 1.5
  bleedChance = techConfig["bleedChance"] or 50
  entityId = entity.id()
end

function update(dt)
  local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
  queryDamageSince = nextStep
  for _, notification in ipairs(damageNotifications) do
    if notification.targetEntityId then
      if notification.sourceEntityId ~= notification.targetEntityId and (notification.damageDealt > minimumDamage) and (notification.damageDealt/percentage > 0) then
        world.sendEntityMessage(notification.sourceEntityId, "applyStatusEffect", "sb_directdamage", notification.damageDealt/percentage, entity.id())
	if math.random(100) <= bleedChance then
          world.sendEntityMessage(notification.sourceEntityId, "applyStatusEffect", "sb_bleed", notification.damageDealt*percentage, entity.id())
	end
      end
    end
  end
end