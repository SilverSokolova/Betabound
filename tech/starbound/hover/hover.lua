function init()
  holdingJump = false
  active = false
  lastActive = false

  hoverControlForce = config.getParameter("hoverControlForce", 250)
  energyUsagePerSecond = config.getParameter("energyUsagePerSecond", 43)
end

function input(args)
  if args.moves["jump"] and mcontroller.jumping() then
    holdingJump = true
  elseif not args.moves["jump"] then
    holdingJump = false
  end

  return
    args.moves["jump"] and
    not mcontroller.canJump() and
    not holdingJump and
    math.floor(world.gravity(mcontroller.position())) > 0 and
--    not mcontroller.liquidMovement() and
    not status.statPositive("activeMovementAbilities") and
    "hover" or nil
end

function update(args)
  local action = input(args)

  if action == "hover" and status.overConsumeResource("energy", energyUsagePerSecond * args.dt) then
    active = true
    mcontroller.controlParameters({gravityEnabled = false})
    animator.setFlipped(mcontroller.facingDirection() == -1)

    if not args.moves["run"] then
      mcontroller.controlApproachVelocity({0, 0}, hoverControlForce)
    end
  else
    active = false
  end

  if active ~= lastActive then
    animator.setAnimationState("jetpack", active and "on" or "off")

    if active then
      animator.playSound("activate")
    end
  end

  lastActive = active
end