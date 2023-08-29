require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()
  self.broadcastArea = config.getParameter("broadcastArea",{4,4,4,4})
  self.spawnRegion = rect.translate(self.broadcastArea, entity.position())

  self.eventSource = config.getParameter("eventSource",0)
  if not self.eventSource then
    stagehand.die()
  end

  self.spawnVehicle = config.getParameter("spawnVehicle","dropship")
  self.vehicleBounds = config.getParameter("vehicleBounds",{4,4,4,4})
  self.vehicleParameters = config.getParameter("vehicleParameters",{})
end

function update(dt)
  local sourcePosition = world.entityExists(self.eventSource) and world.entityPosition(self.eventSource) or false
  if not sourcePosition then
    stagehand.die() return
  end

  local toSource = world.distance(sourcePosition, entity.position())
  local sourceDir = util.toDirection(toSource[1])
  local spawnPoint
  if sourceDir > 0 then
    spawnPoint = rect.ur(self.spawnRegion)
  else
    spawnPoint = rect.ul(self.spawnRegion)
  end
  local spawnBounds = rect.translate(self.vehicleBounds, spawnPoint)
  if not world.isVisibleToPlayer(spawnBounds) then
    self.vehicleParameters.flyDir = -sourceDir
    spawnPoint[1] = spawnPoint[1]-10
    spawnPoint[2] = spawnPoint[2]+20
    world.spawnVehicle(self.spawnVehicle, spawnPoint, self.vehicleParameters)
    stagehand.die()
  end
end

function uninit()
stagehand.die()
end