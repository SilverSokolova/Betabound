function init()
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "sb_pickupladder")

  controlParameters = config.getParameter("controlParameters", {})
  airControlParameters = config.getParameter("airControlParameters", {})
end

function update()
  if not mcontroller.onGround() then
    mcontroller.controlParameters(airControlParameters)
  end
  mcontroller.controlParameters(controlParameters)
end

function uninit()
  mcontroller.setYVelocity(math.min(mcontroller.yVelocity() / 2, mcontroller.yVelocity()))
end