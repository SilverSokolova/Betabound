--TODO: get the bounce sfx to work at high speeds
function init()
  energyUsageRate = config.getParameter("energyUsageRate")
  bounceCollisionPoly = config.getParameter("bounceCollisionPoly")
  bounceFactor = config.getParameter("bounceFactor")
  --wasColliding = false
end

function input(args)
  if args.moves["special1"] == true and not lastAction then
    return active and "deactivate" or "activate"
  end
end

function update(args)
  local action = input(args)

  if action == "activate"
    and not tech.parentLounging()
    and world.resolvePolyCollision(bounceCollisionPoly, mcontroller.position(), 1)
    and status.overConsumeResource("energy", energyUsageRate * args.dt) then
    activate()
  elseif action == "deactivate"
    or (active and (not status.overConsumeResource("energy", energyUsageRate * args.dt) or tech.parentLounging())) then
    deactivate()
  end

  if active then
    --local colliding = mcontroller.isColliding()
    mcontroller.controlParameters({
      standingPoly = bounceCollisionPoly,
      crouchingPoly = bounceCollisionPoly,
      collisionPoly = bounceCollisionPoly,
      bounceFactor = bounceFactor,
      jumpSpeed = 0
    })
    --[[if colliding and not wasColliding then
      animator.playSound("bounce")
    end
    wasColliding = colliding]]
  end
  lastAction = args.moves["special1"]
end

function activate()
  status.setPersistentEffects("sb_bounceTech", {{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})
  active = true
  animator.setAnimationState("bouncing", "on")
  animator.playSound("activate")
end

function deactivate()
  status.clearPersistentEffects("sb_bounceTech")
  active = false
  animator.setAnimationState("bouncing", "off")
  animator.playSound("deactivate")
end

function uninit() status.clearPersistentEffects("sb_bounceTech") end