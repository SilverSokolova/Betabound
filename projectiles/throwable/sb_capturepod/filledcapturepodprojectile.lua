require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  returns = config.getParameter("returns", true)
  releaseOnHit = config.getParameter("releaseOnHit", true)
  controlForce = config.getParameter("controlForce")
  pickupDistance = config.getParameter("pickupDistance")
  snapDistance = config.getParameter("snapDistance")
  speed = config.getParameter("speed")
  returnCollisionDuration = config.getParameter("returnCollisionDuration")
  pureArcDuration = config.getParameter("pureArcDuration")
  returnCollisionPoly = config.getParameter("returnCollisionPoly")
  podUuid = config.getParameter("podUuid")
  ownerId = projectile.sourceEntity()

  returnElapsed = 0
  returning = false
end

function update(dt)
  if not mcontroller.isColliding() then
    preCollisionVelocity = mcontroller.velocity()
  end
 
  if ownerId and world.entityExists(ownerId) then

    if not returning then
      mcontroller.setRotation(0)
      if mcontroller.isColliding() or vec2.mag(mcontroller.velocity()) < 0.1 then
        releaseMonsters()
      end
    else
      returnElapsed = returnElapsed + dt

      local toTarget = world.distance(world.entityPosition(ownerId), mcontroller.position())
      local targetDistance = vec2.mag(toTarget)
      if targetDistance < pickupDistance then
        projectile.die()
      elseif returnElapsed > returnCollisionDuration or targetDistance < snapDistance then
        mcontroller.applyParameters({collisionEnabled = false})
        mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), speed), 500)
      elseif returnElapsed > pureArcDuration then
        mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), speed), controlForce)
      end
    end
  else
    projectile.die()
  end
end

function hit(entityId)
  if releaseOnHit and not returning then
    releaseMonsters()
  end
end

function releaseMonsters()
--[[  if podUuid then
    -- Player filledcapturepod
    world.sendEntityMessage(ownerId, "pets.spawnFromPod", podUuid, mcontroller.position())
  world.spawnItem("sb_capturepod", mcontroller.position(), 1)

    if returns then
      returning = true
      mcontroller.applyParameters({
          collisionPoly = returnCollisionPoly
        })
      mcontroller.setVelocity(vec2.mul(preCollisionVelocity or mcontroller.velocity(), -1))
    else
      projectile.die()
    end
  else]]--
    -- NPC npcpetcapturepod
    local monsterType = config.getParameter("monsterType","punchy")
    local damageTeam = entity.damageTeam()
    local entityId = world.spawnMonster(monsterType, mcontroller.position(), {
        level = config.getParameter("monsterLevel", 1),
        sb_killCount = config.getParameter("sb_killCount", 1),
        damageTeam = damageTeam.team,
        damageTeamType = damageTeam.type,
        aggressive = true
      })
    local position = world.callScriptedEntity(entityId, "findGroundPosition", world.entityPosition(entityId), -10, 10, false)
    if position then
      world.callScriptedEntity(entityId, "mcontroller.setPosition", position)
    end

    projectile.die()

  end
end

function monstersReleased()
  return returning
end
