require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  controlMovement = config.getParameter("controlMovement")
  controlRotation = config.getParameter("controlRotation")
  rotationSpeed = 0
  timedActions = config.getParameter("timedActions", {})

  aimPosition = mcontroller.position()
  oldPosition = {0, 0}

  message.setHandler("updateProjectile", function(_, _, newPosition)
    if world.magnitude(aimPosition, oldPosition) > 2 then
      aimPosition = newPosition
    end
  end)
  message.setHandler("kill", function() projectile.die() end)
end

function update(dt)
  local vel = mcontroller.velocity()
  if math.floor(vel[1]) == 0 and math.floor(vel[2]) == 0 then
    mcontroller.setVelocity({0,0})
  end
  if aimPosition then
    if controlMovement then
      controlTo(aimPosition)
    end

    if controlRotation then
      rotateTo(aimPosition, dt)
    end
  end
end

function controlTo(position)
  local offset = world.distance(position, mcontroller.position())
  mcontroller.approachVelocity(vec2.mul(vec2.norm(offset), controlMovement.maxSpeed), controlMovement.controlForce)
end

function rotateTo(position, dt)
  local vectorTo = world.distance(position, mcontroller.position())
  local angleTo = vec2.angle(vectorTo)
  if controlRotation.maxSpeed then
    local currentRotation = mcontroller.rotation()
    local angleDiff = util.angleDiff(currentRotation, angleTo)
    local diffSign = angleDiff > 0 and 1 or -1

    local targetSpeed = math.max(0.1, math.min(1, math.abs(angleDiff) / 0.5)) * controlRotation.maxSpeed
    local acceleration = diffSign * controlRotation.controlForce * dt
    rotationSpeed = math.max(-targetSpeed, math.min(targetSpeed, rotationSpeed + acceleration))
    rotationSpeed = rotationSpeed - rotationSpeed * controlRotation.friction * dt

    mcontroller.setRotation(currentRotation + rotationSpeed * dt)
  else
    mcontroller.setRotation(angleTo)
  end
end