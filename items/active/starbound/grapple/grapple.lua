require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/rope.lua"

function init()
  hand = "sb_grapple"..activeItem.hand()
  fireOffset = config.getParameter("fireOffset", {0,0})
  self.stances = config.getParameter("stances")
  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters")
  self.returnSpeed = config.getParameter("returnSpeed", 0)
  self.returnDistance = config.getParameter("returnDistance", 1)

  self.previousFireMode = "none"
  self.ropeSegments = {}

  activeItem.setScriptedAnimationParameter("ropeOffset",  config.getParameter("ropeOffset", fireOffset))
  activeItem.setScriptedAnimationParameter("ropeWidth", config.getParameter("ropeWidth"))
  activeItem.setScriptedAnimationParameter("ropeColor", config.getParameter("ropeColor"))
  activeItem.setScriptedAnimationParameter("ropeFullbright", config.getParameter("ropeFullbright"))
  activeItem.setScriptedAnimationParameter("ropeSegments", {})

  setStance("idle")
end

function update(dt, fireMode, shiftHeld)
  self.stanceTimer = math.max(self.stanceTimer - dt, 0)

  checkProjectile()

  if self.stanceName == "idle" then
    if fireMode == "primary" and self.previousFireMode ~= "primary" then
      fire()
    end
  elseif self.stanceName == "active" then
    if not self.projectileId or (fireMode == "primary" and self.previousFireMode ~= "primary") then
      resetRope()
    elseif not self.ropeLength and self.anchored then
      setRopeLength()
    else
      updateRope(fireMode ~= "primary")
    end
  end

  self.previousFireMode = fireMode

  updateAim(self.stance.allowRotate, self.stance.allowFlip)
end

function uninit()
  resetRope()
  if self.projectileId and world.entityExists(self.projectileId) then
    world.callScriptedEntity(self.projectileId, "kill")
  end
end

function fire()
  local projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      self.projectileParameters
    )
  if projectileId then
    self.projectileId = projectileId
    activeItem.setScriptedAnimationParameter("ropeSegments", {"item", self.projectileId})
    setStance("active")
    animator.playSound("fire")
    status.setPersistentEffects(hand, {{stat = "activeMovementAbilities", amount = 0.5}})
    self.inRange = false
  end
end

function setStance(stanceName)
  self.stanceName = stanceName
  self.stance = self.stances[stanceName]
  self.stanceTimer = self.stance.duration or 0
  animator.setAnimationState("weapon", stanceName == "active" and "empty" or "full")
  animator.rotateGroup("weapon", util.toRadians(self.stance.weaponRotation))
  updateAim(self.stance.allowRotate, self.stance.allowFlip)
end

function ropeVector()
  return world.distance(world.entityPosition(self.projectileId), vec2.add(activeItem.handPosition(config.getParameter("ropeOffset", fireOffset)), mcontroller.position()))
end

function setRopeLength()
  self.ropeLength = vec2.mag(ropeVector())
end

function updateRope(doPull)
  -- TODO: all the actually difficult stuff

  local aimVector = world.distance(world.entityPosition(self.projectileId), mcontroller.position())
  self.aimDirection = aimVector[1] < 0 and -1 or 1
  self.aimAngle = vec2.angle({aimVector[1] * self.aimDirection, aimVector[2]})

  if self.anchored then
    local swingAngle = vec2.angle(aimVector)
    self.inRange = self.inRange or vec2.mag(aimVector) < self.returnDistance
    if not self.inRange and doPull then
      mcontroller.controlApproachVelocityAlongAngle(swingAngle, self.returnSpeed, 1000, true)
    elseif not mcontroller.onGround() then
      if doPull then
        mcontroller.controlApproachVelocity({0, 0}, 100)
      end
      mcontroller.controlApproachVelocityAlongAngle(swingAngle, 0, 1000, true)
    end
  end
end

function resetRope()
  if self.projectileId then
    if world.entityExists(self.projectileId) then
      world.callScriptedEntity(self.projectileId, "kill")
    end
    self.projectileId = nil
  end
  setStance("idle")
  activeItem.setScriptedAnimationParameter("ropeSegments", {})
  self.ropeLength = nil
  status.clearPersistentEffects(hand)
end

function checkProjectile()
  if self.projectileId then
    if world.entityExists(self.projectileId) then
      self.anchored = world.callScriptedEntity(self.projectileId, "anchored")
    else
      resetRope()
    end
  end
end

function updateAim(allowRotate, allowFlip)
  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(fireOffset[2], activeItem.ownerAimPosition())
  
  if allowRotate then
    self.aimAngle = aimAngle
  end
  aimAngle = (self.aimAngle or 0) + util.toRadians(self.stance.armRotation)
  activeItem.setArmAngle(aimAngle)

  if allowFlip then
    self.aimDirection = aimDirection
  end
  activeItem.setFacingDirection((self.aimDirection or 0))
end

function firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(fireOffset))
end

function aimVector()
  local aimVector = vec2.rotate({1, 0}, self.aimAngle)
  aimVector[1] = aimVector[1] * self.aimDirection
  return aimVector
end
