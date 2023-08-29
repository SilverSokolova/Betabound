function init()
  holdingJump = false
  active = false
  jetpackSpeed = config.getParameter("jetpackSpeed",20)
  jetpackControlForce = config.getParameter("jetpackControlForce",250)
  energyUsagePerSecond = config.getParameter("energyUsagePerSecond",43)
  enableZeroG = config.getParameter("enableZeroG",false)
  controlXYApproachVelocity = config.getParameter("controlXYApproachVelocity",false)
  stats = config.getParameter("flightStats",{{stat="fallDamageMultiplier",effectiveMultiplier=0.5}})
end

function input(args)
  if args.moves["jump"] and mcontroller.jumping() then
    holdingJump = true
  elseif not args.moves["jump"] then
    holdingJump = false
  end
  return
	  args.moves["jump"] and
	  not args.moves["down"] and
	  not mcontroller.canJump() and
  	not holdingJump and
  	(enableZeroG or not mcontroller.zeroG()) and
	  not mcontroller.liquidMovement() and
	  not status.statPositive("activeMovementAbilities") and
	  "jetpack" or nil
end

function update(args)
  local action = input(args)

  if action and status.overConsumeResource("energy", energyUsagePerSecond * args.dt) then
    animator.setAnimationState("jetpack", "on")
    animator.setFlipped(mcontroller.facingDirection() == -1)
    if controlXYApproachVelocity then
      mcontroller.controlApproachVelocity({jetpackSpeed,jetpackSpeed}, jetpackControlForce)
    else
      mcontroller.controlApproachYVelocity(jetpackSpeed, jetpackControlForce)
    end

    if not active then animator.playSound("activate") end
    active = true
    if stats then status.setPersistentEffects("sb_jetpack",stats) end
  else
    active = false
    animator.setAnimationState("jetpack", "off")
    status.clearPersistentEffects("sb_jetpack")
  end
end