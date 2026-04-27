local originalUpdate = update or function(...) end

function update(...) originalUpdate(...)
  --Manually trigger a jump if we're stuck because I couldn't figure out how to make them do it on their own
  if mcontroller.running() and mcontroller.onGround() and mcontroller.canJump() and (mcontroller.xVelocity() == 0) then
    mcontroller.controlJump()
  end
end