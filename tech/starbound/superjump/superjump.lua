function init()
  superJumpTimer = {0,0}
  superJumpSpeed = config.getParameter("superjumpSpeed")
  superJumpControlForce = config.getParameter("superjumpControlForce")
  superJumpTime = config.getParameter("superjumpTime")
  superJumpCharge = 0
  superJumpMaxCharge = config.getParameter("superJumpMaxCharge")
end

function update(args)
  if args.moves["jump"] and mcontroller.onGround() and superJumpTimer[1] <= 0 and superJumpCharge <= superJumpMaxCharge then
    superJumpCharge = superJumpCharge + 0.1
  elseif
    superJumpCharge > 0.1 then superJumpCharge = superJumpCharge - 0.1
  end

  animator.setParticleEmitterActive("chargedParticles",superJumpCharge >= 8)

  if superJumpCharge >= 1 and superJumpCharge <= 1.1 and mcontroller.onGround() and args.moves["jump"] then animator.playSound("charge") end
  if args.moves["jump"] and args.moves["up"] and mcontroller.onGround() and superJumpTimer[1] <= 0 and status.overConsumeResource("energy", config.getParameter("energyUsage")) then
    animator.playSound("jumpSound")
    superJumpTimer = {superJumpTime,superJumpTime*3}
  end

  animator.setFlipped(mcontroller.facingDirection() < 0)

  if superJumpTimer[1] > 0 then
    mcontroller.controlApproachYVelocity(superJumpSpeed+(superJumpCharge*(superJumpCharge*3)), superJumpControlForce+(superJumpCharge*superJumpCharge*3))
    animator.setParticleEmitterActive("jumpParticles", true)
    superJumpTimer[1] = superJumpTimer[1] - args.dt
  else
    animator.setParticleEmitterActive("jumpParticles", false)
  end
  if superJumpTimer[2] > 0 then
    animator.setParticleEmitterActive("rocketParticles", true)
    superJumpTimer[2] = superJumpTimer[2] - args.dt
  else
    animator.setParticleEmitterActive("rocketParticles", false)
  end
end
