local originalInit = init or function() end
local originalUpdate = update or function(...) end
function init() originalInit()
  if not status.statusProperty("sb_minibossSpawned") then
    status.addEphemeralEffect("sb_minibossspawn")
    status.setStatusProperty("sb_minibossSpawned", true)
  end
end

function update(...) originalUpdate(...)
  if mcontroller.running() and mcontroller.onGround() and mcontroller.canJump() and (mcontroller.xVelocity() == 0) then
    mcontroller.controlJump()
  end
end