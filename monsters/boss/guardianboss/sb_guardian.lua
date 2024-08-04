local originalInit = init or function() end
--This is specifically because they should be invulnerable when they have a ton of defense, and our changes to defense scaling undoes that
function init() originalInit()
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