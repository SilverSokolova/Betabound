--TODO: rewrite this completely
--We need to temporarily supress jumping so the player doesn't initiate a regular jump and cancel their approachYVelocity
function init()
  superJumpTimer = {0,0}
  superJumpSpeed = config.getParameter("superjumpSpeed")
  superJumpControlForce = config.getParameter("superjumpControlForce")
  superJumpTime = config.getParameter("superjumpTime")
  superJumpCharge = 0
  superJumpMaxCharge = config.getParameter("superJumpMaxCharge")
end

function update(args)
  local activeMovementAbility = status.statPositive("activeMovementAbilities")
  if not activeMovementAbility and args.moves["up"] and mcontroller.onGround() then
    mcontroller.controlModifiers({jumpingSuppressed = true})
  end

  if not activeMovementAbility and args.moves["up"] and mcontroller.onGround() and superJumpTimer[1] <= 0 and superJumpCharge <= superJumpMaxCharge then
    superJumpCharge = superJumpCharge + 0.1
  elseif
    superJumpCharge > 0.1 then superJumpCharge = superJumpCharge - 0.1
  end

  if not activeMovementAbility then
    animator.setParticleEmitterActive("chargedParticles", superJumpCharge >= 8)

    if superJumpCharge >= 1 and superJumpCharge <= 1.1 and mcontroller.onGround() and args.moves["up"] then animator.playSound("charge") end
    if args.moves["up"] and args.moves["jump"] and mcontroller.onGround() and superJumpTimer[1] <= 0 and status.overConsumeResource("energy", config.getParameter("energyUsage")) then
      animator.playSound("jumpSound")
      superJumpTimer = {superJumpTime, superJumpTime*3}
    end

    animator.setFlipped(mcontroller.facingDirection() < 0)

    if superJumpTimer[1] > 0 then
      
    mcontroller.controlModifiers({jumpingSuppressed = true})
      mcontroller.controlApproachYVelocity(superJumpSpeed+(superJumpCharge*(superJumpCharge*3)), superJumpControlForce+(superJumpCharge*superJumpCharge*3) + world.gravity(mcontroller.position()))
      superJumpTimer[1] = superJumpTimer[1] - args.dt
    else
    end
    if superJumpTimer[2] > 0 then
      animator.setParticleEmitterActive("jumpParticles", true)
      animator.setParticleEmitterActive("rocketParticles", true)
      superJumpTimer[2] = superJumpTimer[2] - args.dt
    else
      animator.setParticleEmitterActive("jumpParticles", false)
      animator.setParticleEmitterActive("rocketParticles", false)
    end
  else
    animator.setParticleEmitterActive("chargedParticles", false)
    animator.setParticleEmitterActive("jumpParticles", false)
    animator.setParticleEmitterActive("rocketParticles", false)
  end
end
