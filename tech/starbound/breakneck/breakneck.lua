function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  maximumVelocity = techConfig["maximumVelocity"] or 3
  maximumAnimatedVelocity = techConfig["maximumAnimatedVelocity"] or maximumVelocity
  velocityIncrease = techConfig["velocityIncrease"] or 0.005
  velocityDecrease = -(techConfig["velocityDecrease"] or 0.05)
  airVelocityDecrease = techConfig["airVelocityDecrease"] or 0.005
  turnVelocityDecrease = techConfig["turnVelocityDecrease"] or 3
  groundFrictionFactor = techConfig["groundFrictionFactor"] or 10
  velocity = 0
  highestSprint = 0
  airTime = 0
  lastMovementDirection = mcontroller.movingDirection()

  offsettedEmitters = config.getParameter("particleEmitterOffset")
  if offsettedEmitters then
    local bounds = mcontroller.boundBox()
    bounds = {bounds[1], bounds[2] + 0.2, bounds[3], bounds[2] + 0.3}
    for k, _ in pairs(offsettedEmitters) do
      animator.setParticleEmitterOffsetRegion(k, bounds)
    end
  end
end

function update()
--world.debugText("^shadow;%s", airTime, mcontroller.position(), "green")
  if not player then player = math.betabound_player return end
  if not player.loungingIn() then
    local xVelocity = mcontroller.xVelocity()
    if mcontroller.onGround() then
      airTime = 0
      local newVelocity = mcontroller.running() and (math.max(velocityIncrease, xVelocity/10000)) or velocityDecrease
      velocity = math.min(maximumVelocity, math.max(0, velocity + newVelocity))
    else
      airTime = airTime + 1
      if airTime > 50 then
        velocity = math.max(0, velocity - airVelocityDecrease)
      end
    end
    local newMovementDirection = mcontroller.movingDirection()
    if lastMovementDirection ~= newMovementDirection then
      velocity = math.max(0, velocity/turnVelocityDecrease)
    end
    lastMovementDirection = newMovementDirection
    mcontroller.controlParameters({normalGroundFriction = mcontroller.baseParameters().normalGroundFriction - (velocity * groundFrictionFactor)})
    mcontroller.controlModifiers({speedModifier = 1 + velocity})

    toggleAnimation(velocity >= 1 and velocity <= maximumVelocity, math.floor(velocity), math.floor(xVelocity))
  end
end

function toggleAnimation(bool, highest, xVelocity)
  animator.setFlipped(mcontroller.facingDirection() == -1)
  if bool then
    bool = mcontroller.running() and (xVelocity ~= 0)
  end
  animator.setAnimationState("sound", bool and "on" or "off")
  for i = 1, maximumAnimatedVelocity do
    bool = airTime < 15 and i <= highest
    if status.statPositive("activeMovementAbilities") then
      bool = false
    end
    local target = "particles"..i
    if offsettedEmitters and offsettedEmitters[target] then
      animator.setParticleEmitterActive(target, mcontroller.onGround() and bool)
    else
      animator.setParticleEmitterActive(target, bool)
    end
  end
end