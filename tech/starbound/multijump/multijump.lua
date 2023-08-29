function init()
  multiJumps = 0
  lastJump = false
end

function input(args)
  if args.moves["jump"]
  and not mcontroller.jumping()
  and not mcontroller.canJump()
  and not mcontroller.zeroG()
  and not status.statPositive("activeMovementAbilities")
  and not lastJump then
    lastJump = true
    return "multiJump"
  else
    lastJump = args.moves["jump"]
    return nil
  end
end

function update(args)
  local action = input(args)
  local multiJumpCount = config.getParameter("multiJumpCount")
  local energyUsage = config.getParameter("energyUsage")

  if action == "multiJump" and multiJumps < multiJumpCount and (energyUsage == 0 or status.overConsumeResource("energy", energyUsage)) then
    mcontroller.controlJump(true)
    multiJumps = multiJumps + 1
    animator.burstParticleEmitter("multiJumpParticles")
    animator.playSound("multiJumpSound")
  else
    if mcontroller.onGround() or mcontroller.liquidMovement() then
      multiJumps = 0
    end
  end
end
