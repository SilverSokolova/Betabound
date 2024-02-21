function init()
  items = config.getParameter("items")
  killedEntities = {}
end

function update()
  local damageNotificationsOutgoing, nextStep = status.inflictedDamageSince(queryDamageSince)
  queryDamageSince = nextStep
  for k, notification in ipairs(damageNotificationsOutgoing) do
    if notification.targetEntityId then
      if notification.sourceEntityId ~= notification.targetEntityId then
        if notification.hitType == "Kill" and (notification.targetMaterialKind ~= "Solid" and notification.healthLost ~= 1) and not killedEntities[notification.targetEntityId] then
          killedEntities[notification.targetEntityId] = 1
          local killCount = world.getProperty("sb_killCount", 0) + 1
          world.setProperty("sb_killCount", killCount)
          local item = items[killCount..""]
          if item then
            world.spawnItem(item, notification.position)
          end
        end
      end
    end
  end
end