--Identical to vanilla except without self. Do we need this?
require "/scripts/vec2.lua"

function init()
  initCommonParameters()
end

function initCommonParameters()
  angularVelocity = 0
  angle = 0
  transformFadeTimer = 0

  energyCost = config.getParameter("energyCost")
  ballRadius = config.getParameter("ballRadius")
  ballFrames = config.getParameter("ballFrames")
  ballSpeed = config.getParameter("ballSpeed")
  transformFadeTime = config.getParameter("transformFadeTime", 0.3)
  transformedMovementParameters = config.getParameter("transformedMovementParameters")
  transformedMovementParameters.runSpeed = ballSpeed
  transformedMovementParameters.walkSpeed = ballSpeed
  basePoly = mcontroller.baseParameters().standingPoly
  collisionSet = {"Null", "Block", "Dynamic", "Slippery"}

  forceDeactivateTime = config.getParameter("forceDeactivateTime", 3.0)
  forceShakeMagnitude = config.getParameter("forceShakeMagnitude", 0.125)
end

function uninit()
  storePosition()
  deactivate()
end

function update(args)
  restoreStoredPosition()

  if not specialLast and args.moves["special1"] then
    attemptActivation()
  end
  specialLast = args.moves["special1"]

  if not args.moves["special1"] then
    forceTimer = nil
  end

  if active then
    mcontroller.controlParameters(transformedMovementParameters)
    status.setResourcePercentage("energyRegenBlock", 1.0)

    updateAngularVelocity(args.dt)
    updateRotationFrame(args.dt)

    checkForceDeactivate(args.dt)
  end

  updateTransformFade(args.dt)

  lastPosition = mcontroller.position()
end

function attemptActivation()
  if not active
      and not tech.parentLounging()
      and not status.statPositive("activeMovementAbilities")
      and status.overConsumeResource("energy", energyCost) then

    local pos = transformPosition()
    if pos then
      mcontroller.setPosition(pos)
      activate()
    end
  elseif active then
    local pos = restorePosition()
    if pos then
      mcontroller.setPosition(pos)
      deactivate()
    elseif not forceTimer then
      animator.playSound("forceDeactivate", -1)
      forceTimer = 0
    end
  end
end

function checkForceDeactivate(dt)
  animator.resetTransformationGroup("ball")

  if forceTimer then
    forceTimer = forceTimer + dt
    mcontroller.controlModifiers({
      movementSuppressed = true
    })

    local shake = vec2.mul(vec2.withAngle((math.random() * math.pi * 2), forceShakeMagnitude), forceTimer / forceDeactivateTime)
    animator.translateTransformationGroup("ball", shake)
    if forceTimer >= forceDeactivateTime then
      deactivate()
      forceTimer = nil
    else
      attemptActivation()
    end
    return true
  else
    animator.stopAllSounds("forceDeactivate")
    return false
  end
end

function storePosition()
  if active then
    storage.restorePosition = restorePosition()

    -- try to restore position. if techs are being switched, this will work and the storage will
    -- be cleared anyway. if the client's disconnecting, this won't work but the storage will remain to
    -- restore the position later in update()
    if storage.restorePosition then
      storage.lastActivePosition = mcontroller.position()
      mcontroller.setPosition(storage.restorePosition)
    end
  end
end

function restoreStoredPosition()
  if storage.restorePosition then
    -- restore position if the player was logged out (in the same planet/universe) with the tech active
    if vec2.mag(vec2.sub(mcontroller.position(), storage.lastActivePosition)) < 1 then
      mcontroller.setPosition(storage.restorePosition)
    end
    storage.lastActivePosition = nil
    storage.restorePosition = nil
  end
end

function updateAngularVelocity(dt)
  if mcontroller.groundMovement() then
    -- If we are on the ground, assume we are rolling without slipping to
    -- determine the angular velocity
    local positionDiff = world.distance(lastPosition or mcontroller.position(), mcontroller.position())
    angularVelocity = -vec2.mag(positionDiff) / dt / ballRadius

    if positionDiff[1] > 0 then
      angularVelocity = -angularVelocity
    end
  end
end

function updateRotationFrame(dt)
  angle = math.fmod(math.pi * 2 + angle + angularVelocity * dt, math.pi * 2)

  -- Rotation frames for the ball are given as one *half* rotation so two
  -- full cycles of each of the ball frames completes a total rotation.
  local rotationFrame = math.floor(angle / math.pi * ballFrames) % ballFrames
  animator.setGlobalTag("rotationFrame", rotationFrame)
end

function updateTransformFade(dt)
  if transformFadeTimer > 0 then
    transformFadeTimer = math.max(0, transformFadeTimer - dt)
    animator.setGlobalTag("ballDirectives", string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, transformFadeTimer / (transformFadeTime - 0.15))))
  elseif transformFadeTimer < 0 then
    transformFadeTimer = math.min(0, transformFadeTimer + dt)
    tech.setParentDirectives(string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, -transformFadeTimer / (transformFadeTime - 0.15))))
  else
    animator.setGlobalTag("ballDirectives", "")
    tech.setParentDirectives()
  end
end

function positionOffset()
  return minY(transformedMovementParameters.collisionPoly) - minY(basePoly)
end

function transformPosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(transformedMovementParameters.collisionPoly, {pos[1], pos[2] - positionOffset()}, 1, collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(transformedMovementParameters.collisionPoly, pos, 1, collisionSet)
  end
end

function restorePosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(basePoly, {pos[1], pos[2] + positionOffset()}, 1, collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(basePoly, pos, 1, collisionSet)
  end
end

function activate()
  if not active then
    animator.burstParticleEmitter("activateParticles")
    animator.playSound("activate")
    animator.setAnimationState("ballState", "activate")
    angularVelocity = 0
    angle = 0
    transformFadeTimer = transformFadeTime
  end
  tech.setParentHidden(true)
  tech.setParentOffset({0, positionOffset()})
  tech.setToolUsageSuppressed(true)
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  active = true
end

function deactivate()
  if active then
    animator.burstParticleEmitter("deactivateParticles")
    animator.playSound("deactivate")
    animator.setAnimationState("ballState", "deactivate")
    transformFadeTimer = -transformFadeTime
  else
    animator.setAnimationState("ballState", "off")
  end
  animator.stopAllSounds("forceDeactivate")
  animator.setGlobalTag("ballDirectives", "")
  tech.setParentHidden(false)
  tech.setParentOffset({0, 0})
  tech.setToolUsageSuppressed(false)
  status.clearPersistentEffects("movementAbility")
  angle = 0
  active = false
end

function minY(poly)
  local lowest = 0
  for _,point in pairs(poly) do
    if point[2] < lowest then
      lowest = point[2]
    end
  end
  return lowest
end
