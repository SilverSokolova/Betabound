function init()
  lastJump = false
  lastBoost = nil
  boostControlForce = config.getParameter("boostControlForce")
  boostSpeed = config.getParameter("boostSpeed")
  energyUsagePerSecond = config.getParameter("energyUsagePerSecond")
  diag = 1 / math.sqrt(2)
end

function update(args)
  local currentBoost = false

  if not mcontroller.onGround() and not status.statPositive("activeMovementAbilities") then
    if not mcontroller.canJump() and args.moves["jump"] and not lastJump then
      currentBoost = {
        args.moves["right"] and boostSpeed or args.moves["left"] and -boostSpeed or 0,
        args.moves["up"] and boostSpeed or args.moves["down"] and -boostSpeed or 0
      }
      if (args.moves["right"] or args.moves["left"]) and (args.moves["up"] or args.moves["down"]) then
        currentBoost = {currentBoost[1] * diag, currentBoost[2] * diag}
      end
    elseif args.moves["jump"] and lastBoost then
      currentBoost = lastBoost
    end
    if currentBoost and (currentBoost[1] == 0 and currentBoost[2] == 0) then
      currentBoost = false
    end
  end

  lastJump = args.moves["jump"]
  lastBoost = currentBoost

  if currentBoost and status.overConsumeResource("energy", energyUsagePerSecond * args.dt) then
    mcontroller.controlApproachVelocity(currentBoost, boostControlForce)

    animator.setAnimationState("boosting", "on")
    animator.setParticleEmitterActive("boostParticles", true)
  else
    animator.setAnimationState("boosting", "off")
    animator.setParticleEmitterActive("boostParticles", false)
  end
end