require "/scripts/vec2.lua"

function init()
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "sb_pickupladder")
end

function update()
  if not mcontroller.onGround() then
    mcontroller.controlParameters({airFriction = 6})
  end
  mcontroller.controlParameters({
    airForce = 100,
    airJumpProfile = {
      jumpSpeed = 20,
      jumpHoldTime = 0.01,
      reJumpDelay = 0.01,
      jumpInitialPercentage = 0.05,
      jumpControlForce = 100000,
      multiJump = true,
      autoJump = true,
    }
  })
end

function uninit()
  mcontroller.setYVelocity(math.min(mcontroller.yVelocity() / 2, mcontroller.yVelocity()))
end