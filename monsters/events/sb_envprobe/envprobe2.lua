require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/companions/capturable.lua"

--TODO: Not prefixing the probe functions seems fine for now but it'll probably cause problems later. See you in 2034
local originalInit = init or function() end
function init()
  originalInit()
  self.dialog = config.getParameter("dialog")

  mcontroller.controlFace(1)
  script.setUpdateDelta(3)

  self.target = nil

  self.state = FSM:new()
  self.state:set(scanTarget)
  self.attack = FSM:new()

  self.lightning = config.getParameter("lightning")
end

local sb_update = update or function() end
function update(dt)
  sb_update(dt)
  capturable.update(dt)
  mcontroller.controlFace(1)
  mcontroller.controlDown()
  
  if status.resourcePositive("stunned") then
    animator.setAnimationState("damage", "stunned")
    monster.setAnimationParameter("lightning", {})
    mcontroller.clearControls()
    -- stop attacking on taking damage
    self.attack:set(nil)
    return
  else
    animator.setAnimationState("damage", "none")
  end

  self.state:update(dt)
  self.attack:update(dt)
end

function attack()
  animator.setAnimationState("body", "aggro")
  if math.random() < 0.25 then
    monster.say(util.randomFromList(self.dialog.aggro))
    util.wait(1.0)
  else
    util.wait(0.2)
  end

  local targetPosition = world.entityPosition(self.target)
  if targetPosition then
    self.lightning[1].worldEndPosition = targetPosition
    monster.setAnimationParameter("lightning", self.lightning)
    world.spawnProjectile("shock", targetPosition, entity.id(), {0, 0}, false, {power = 3})

    util.wait(0.1)
  end

  monster.setAnimationParameter("lightning", {})

  util.wait(1.0)

  animator.setAnimationState("body", "idle")
  self.attack:set(nil)
end

function scanTarget(dt)
  while self.target == nil do
    local players = world.entityQuery(mcontroller.position(), 50, { includedTypes = { "player" }, order = "nearest" })
    if #players > 0 then
      self.target = players[1]
      world.sendEntityMessage(self.target, "listenTileBroken", entity.id())
      world.sendEntityMessage(self.target, "listenTileEntityBroken", entity.id())
    end

    util.wait(0.5)
  end

  local approached = false
  local angle = 0
  while self.target ~= nil and world.entityExists(self.target) do
    local targetPosition = world.entityPosition(self.target)
    local toTarget = world.distance(targetPosition, mcontroller.position())
    local targetDistance = vec2.mag(toTarget)
    local targetAngle = vec2.angle(toTarget)

    -- vectors out to the sides, and points at the edge of the probe
    local radius = mcontroller.boundBox()[3] -- right side of the bound box is the radius
    local left = vec2.rotate({0.0, 1.0}, targetAngle)
    local leftEdge = vec2.add(mcontroller.position(), vec2.mul(left, radius))
    local right = vec2.rotate({0.0, -1.0}, targetAngle)
    local rightEdge = vec2.add(mcontroller.position(), vec2.mul(right, radius))
    
    -- Check LOS from edges of the probe to the player
    local inSight = not world.lineTileCollision(leftEdge, targetPosition)
      and not world.lineTileCollision(rightEdge, targetPosition)

    if not inSight then
      local searchParameters = {
        returnBest = false,
        mustEndOnGround = false,
        maxFScore = 400,
        maxNodesToSearch = 70000,
        boundBox = mcontroller.boundBox()
      }
      mcontroller.controlPathMove(targetPosition, false, searchParameters)
      if mcontroller.pathfinding() then
        mcontroller.controlApproachVelocity(vec2.mul(vec2.norm(toTarget), mcontroller.baseParameters().flySpeed), mcontroller.baseParameters().airForce)
      end
    else
      local approachDistance = 10
      local toApproach = targetDistance - approachDistance
      local approachFactor = math.max(math.min(toApproach / approachDistance, 1.0), -1.0)
      
      -- Move toward approachDistance from player
      local flySpeed = mcontroller.baseParameters().flySpeed
      local approach = vec2.mul(vec2.norm(toTarget), flySpeed * approachFactor)

      -- Stay away from blocks on the sides
      local edgeRange = 5
      local back = vec2.rotate({-1.0, 0.0}, targetAngle)
      for _, dir in ipairs({left, right, back}) do
        local edge = vec2.add(mcontroller.position(), vec2.mul(dir, radius))
        local outer = vec2.add(edge, vec2.mul(dir, edgeRange * 2))
        local collision = world.lineTileCollisionPoint(edge, outer)
        if collision then
          local dist = world.magnitude(edge, collision[1])
          approach = vec2.add(approach, vec2.mul(dir, math.min(0.0, -(edgeRange - dist) / edgeRange * vec2.mag(approach))))
        end
      end

      mcontroller.controlApproachVelocity(approach, mcontroller.baseParameters().airForce)
    end

    if inSight and targetDistance < 20 then
      if not approached then
        monster.say(util.randomFromList(self.dialog.approach))
        approached = true
      end

      animator.setLightActive("scan", true)
  --  else
--      animator.setLightActive("scan", false)
    end

    angle = angle + util.angleDiff(angle, targetAngle) * script.updateDt() * 4
    animator.resetTransformationGroup("body")
    animator.rotateTransformationGroup("body", angle)

    if targetDistance > 250 then
      break
    end

    coroutine.yield()
  end
end

function vanish()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end

function shouldDie()
  return (status.resource("health") <= 0) or capturable.justCaptured
end