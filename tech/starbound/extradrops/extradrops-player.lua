function init()
  effects = config.getParameter("effects")
  id = entity.id()
end

function update(dt)
  local damageNotificationsOutgoing, nextStep = status.inflictedDamageSince(queryDamageSince)
  queryDamageSince = nextStep
  for _, notification in ipairs(damageNotificationsOutgoing) do
    if notification.targetEntityId then
      if notification.sourceEntityId ~= notification.targetEntityId then
        world.sendEntityMessage(notification.targetEntityId, "applyStatusEffect", effects[1])
        if world.entityCurrency(id, "essence") > 0 then
          world.sendEntityMessage(notification.targetEntityId, "applyStatusEffect", effects[2])
        end
      end
    end
  end
end