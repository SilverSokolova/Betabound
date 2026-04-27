require "/scripts/vec2.lua"
require "/tech/starbound/morphball/distortionsphere.lua" --TODO: require vanilla one? would need to prefix some variables with 'self'
require "/tech/doubletap.lua"

function init()
  angularVelocity = 0
  angle = 0
  transformFadeTimer = 0
  active = false
  tech.setVisible(false)
  action = nil

  energyPerSecond = config.getParameter("energyCostPerSecond")
  dashControlForce = config.getParameter("dashControlForce")
  dashSpeed = config.getParameter("dashSpeed")
  ballRadius = config.getParameter("ballRadius")
  ballFrames = config.getParameter("ballFrames")
  transformedMovementParameters = config.getParameter("transformedMovementParameters")
  basePoly = mcontroller.baseParameters().standingPoly
  collisionSet = {"Null", "Block", "Dynamic", "Slippery"}
  maximumDoubleTapTime = config.getParameter("maximumDoubleTapTime", 0.2)

  doubleTap = DoubleTap:new({"left", "right"}, maximumDoubleTapTime, function(dir)
    dashDirection = dir
  end)
end

function update(args); doubleTap:update(args.dt, args.moves)
  restoreStoredPosition()

  if dashDirection and mcontroller.onGround() and not status.statPositive("activeMovementAbilities") and status.overConsumeResource("energy", energyPerSecond * args.dt) then
    local pos = transformPosition()
    if pos then
      mcontroller.setPosition(pos)
    end
    activate()

  --Check for left and right instead of what's being held to allow switching directions without exiting ball form
  elseif active and (args.moves["left"] or args.moves["right"]) and status.overConsumeResource("energy", energyPerSecond * args.dt) then
    dashDirection = args.moves["left"] and "left" or args.moves["right"] and "right"
    mcontroller.controlParameters(transformedMovementParameters)
    mcontroller.controlApproachXVelocity((dashDirection == "left" and -1 or 1) * dashSpeed, dashControlForce)
    updateAngularVelocity(args.dt)
    updateRotationFrame(args.dt)
  else
    deactivate()
  end
  updateTransformFade(args.dt)
  lastPosition = mcontroller.position()
end

function activate()
  toggle("", true)
  tech.setParentOffset({0, positionOffset()})
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  status.setPersistentEffects("sb_disableBreakneck", {{stat = "sb_disableBreakneck", amount = 1}})
--  animator.burstParticleEmitter("morphballActivateParticles")
--  tech.setParentDirectives("?multiply=0000")
  self.angularVelocity = 0
  active = true
end

function deactivate()
  if active == true then
    toggle("de", false)
    storePosition()
    tech.setParentOffset({0, 0})
--  animator.burstParticleEmitter("morphballDeactivateParticles")
--  tech.setParentDirectives()
    dashDirection = nil
    active = false
    status.clearPersistentEffects("movementAbility")
    status.clearPersistentEffects("sb_disableBreakneck")
  end
end

function toggle(state, boolean)
  animator.burstParticleEmitter(state .. "activateParticles")
  animator.playSound(state .. "activate")
  animator.setAnimationState("ballState", state .. "activate")
  tech.setVisible(boolean)
  tech.setParentHidden(boolean)
  tech.setToolUsageSuppressed(boolean)

  self.angle = 0
end

function uninit()
  status.clearPersistentEffects("movementAbility")
  status.clearPersistentEffects("sb_disableBreakneck")
end