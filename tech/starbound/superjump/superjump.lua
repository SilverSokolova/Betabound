--We can't discharge the jump during a jump- that cuts it off early
--We need to temporarily supress jumping both while charging and while barely touching the ground so the player doesn't initiate a regular jump and cancel their approachYVelocity
function init()
  superJumpCooldown = 0
  superJumpAnimationDuration = 0
  superJumpSpeed = config.getParameter("superJumpSpeed")
  superJumpControlForce = config.getParameter("superJumpControlForce")
  superJumpDuration = config.getParameter("superJumpDuration")
  superJumpCharge = 0
  superJumpMaxCharge = config.getParameter("superJumpMaxCharge")
  superJumpChargeRate = config.getParameter("superJumpChargeRate")
  energyUsage = config.getParameter("energyUsage")
  chargeParticleBaseEmissionRate = config.getParameter("chargeParticleBaseEmissionRate", 20)
end

function update(args)
  local hasActiveMovementAbility = status.statPositive("activeMovementAbilities")

  --charging
  if not hasActiveMovementAbility then
    if args.moves["up"] and mcontroller.onGround() then
      if superJumpCharge == 0 then
        animator.playSound("charge")
        animator.setParticleEmitterEmissionRate("chargeParticles", superJumpCharge + chargeParticleBaseEmissionRate)
      end

      superJumpCharge = math.min(superJumpMaxCharge, superJumpCharge + superJumpChargeRate)
      mcontroller.controlModifiers({jumpingSuppressed = true}) --Suppress jumping while charging to allow use of the jump button
      
      if args.moves["jump"] and superJumpCharge > 0 and superJumpCooldown == 0 and status.overConsumeResource("energy", energyUsage) then
        superJumpCooldown = superJumpDuration
        superJumpAnimationDuration = superJumpDuration * 3
        animator.playSound("jump")
      end
    end
  end

  --jumping
  if superJumpCooldown > 0 then
    local superJumpStrength = 3 * math.floor(superJumpCharge) ^ 2
    mcontroller.controlModifiers({jumpingSuppressed = true}) --Suppress jumping while jumping as to not have the player jump once they are a literal pixel off the ground
    mcontroller.controlApproachYVelocity(superJumpSpeed + superJumpStrength, superJumpControlForce + superJumpStrength + world.gravity(mcontroller.position()))
  end

  --animation
  animator.setParticleEmitterActive("chargeParticles", superJumpCharge >= 1)
  animator.setFlipped(mcontroller.facingDirection() < 0)
  if superJumpAnimationDuration > 0 then
    animator.setParticleEmitterActive("jumpParticles", true)
    animator.setParticleEmitterActive("rocketParticles", true)

    superJumpAnimationDuration = superJumpAnimationDuration - args.dt
  else
    animator.setParticleEmitterActive("jumpParticles", false)
    animator.setParticleEmitterActive("rocketParticles", false)
  end

  --discharging
  if not args.moves["up"] or hasActiveMovementAbility or not mcontroller.onGround() then
    superJumpCharge = math.max(0, superJumpCharge - superJumpChargeRate)
    animator.setParticleEmitterEmissionRate("chargeParticles", superJumpCharge)
  end

  superJumpCooldown = math.max(0, superJumpCooldown - args.dt)
end