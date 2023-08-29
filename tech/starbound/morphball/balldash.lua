require "/scripts/vec2.lua"
require "/tech/starbound/morphball/distortionsphere.lua"

function init()
  specialLast = false
  lastXPosition = nil
  angularVelocity = 0
  angle = 0
  transformFadeTimer = 0
  active = false
  tech.setVisible(false)

  energyPerSecond = config.getParameter("energyCostPerSecond")
  dashControlForce = config.getParameter("dashControlForce")
  dashSpeed = config.getParameter("dashSpeed")
  ballRadius = config.getParameter("ballRadius")
  ballFrames = config.getParameter("ballFrames")
  transformedMovementParameters = config.getParameter("transformedMovementParameters")
  basePoly = mcontroller.baseParameters().standingPoly
  collisionSet = {"Null", "Block", "Dynamic", "Slippery"}

  doubleTapTimers = {left=0,right=0}
  inputs = {}
  actions = {right="dashRight",left="dashLeft"}
end

function input(args)
  for dir,timer in pairs(doubleTapTimers) do
    doubleTapTimers[dir] = timer - args.dt

    if args.moves[dir] then
      if not inputs[dir] then
	if doubleTapTimers[dir] > 0 then
	  inputs[dir] = true
	  return actions[dir]
	else
	  doubleTapTimers[dir] = config.getParameter("maxDoubleTapTime")
	end
      end
      inputs[dir] = true
    else
      inputs[dir] = false
    end
  end
end

function update(args)
  restoreStoredPosition()
  local action = input(args)
  if (action == "dashLeft" or action == "dashRight") and mcontroller.onGround() and not status.statPositive("activeMovementAbilities") and status.overConsumeResource("energy", energyPerSecond * args.dt) then
    dashDirection = action == "dashLeft" and "left" or "right"
--  local transformPosition = transformPoly(transformedMovementParameters.standingPoly)
    local transformPosition = transformedMovementParameters.standingPoly
      if transformPosition then mcontroller.setPosition(transformPosition) end
      activate()
    elseif active and inputs[dashDirection] and status.overConsumeResource("energy", energyPerSecond * args.dt) then
      local dir = 1
      if dashDirection == "left" then dir = -1 end
      mcontroller.controlParameters(transformedMovementParameters)
      mcontroller.controlApproachXVelocity(dir * dashSpeed, dashControlForce)
      updateAngularVelocity(args.dt)
      updateRotationFrame(args.dt)
    else deactivate() end
  updateTransformFade(args.dt)
  lastPosition = mcontroller.position()
end

function activate()
  animator.burstParticleEmitter("activateParticles")
  animator.playSound("activate")
  animator.setAnimationState("ballState", "activate")
  tech.setParentOffset({0, positionOffset()})
  tech.setVisible(true)
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  tech.setParentHidden(true)
--  animator.burstParticleEmitter("morphballActivateParticles")
--  tech.setParentDirectives("?multiply=0000")
  tech.setToolUsageSuppressed(true)
  active = true
end

function deactivate()
  if active == true then
  storePosition()
  animator.burstParticleEmitter("deactivateParticles")
  animator.playSound("deactivate")
  animator.setAnimationState("ballState", "deactivate")
  tech.setParentOffset({0, 0})
  tech.setVisible(false)
  tech.setParentHidden(false)
--  animator.burstParticleEmitter("morphballDeactivateParticles")
--  tech.setParentDirectives()
  tech.setToolUsageSuppressed(false)
  lastXPosition = nil
  angle = 0
  active = false
  status.clearPersistentEffects("movementAbility")
 end
end