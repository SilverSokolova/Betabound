local ini = init or function() end

function init() ini()
  self.damageTaken = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.healthLost == 5 then
--      if notification.healthLost > 0 and world.entityType(notification.sourceEntityId) == "object" then
        self.damaged = true
        self.board:setEntity("damageSource", notification.sourceEntityId)
      elseif self.shielded then
        animator.setAnimationState("shield", "hit", true)
      end
    end
  end)
end