require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  rotationRate = config.getParameter("rotationRate", 30)
  targetPosition = mcontroller.position()
  message.setHandler("setTargetPosition", function(_, _, newPosition)
    targetPosition = newPosition
  end)
  message.setHandler("kill", function() projectile.die() end)
end

function update(dt)
  if targetPosition then
    world.spawnItem("money", targetPosition)
    local toTarget = world.distance(targetPosition, mcontroller.position())

    local curVel = mcontroller.velocity()
    local curAngle = vec2.angle(curVel)

    local toTargetAngle = util.angleDiff(curAngle, vec2.angle(toTarget))

--  if math.abs(toTargetAngle) > self.trackingLimit then
--    return
--  end

    local rotateAngle = math.max(dt * -rotationRate, math.min(toTargetAngle, dt * rotationRate))

    mcontroller.setVelocity(vec2.rotate(curVel, rotateAngle))
  end
  mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
end