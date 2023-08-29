require "/scripts/util.lua"
require "/scripts/pathutil.lua"

function init()
  self.eventSource = config.getParameter("eventSource")
  self.portalBounds = config.getParameter("portalBounds")
end

function update(dt)
  local sourcePosition = world.entityExists(self.eventSource) and world.entityPosition(self.eventSource) or false
  if not sourcePosition then
    stagehand.die()
  end

  local dist = world.magnitude(entity.position(), sourcePosition)
  local inSight = not world.lineTileCollision(entity.position(), sourcePosition)
  if dist < 30 and inSight then
    local start = vec2.add(entity.position(), {0, 10})
    local top = 5
    for y = 0, 20 do
      local bounds = rect.translate(self.portalBounds, vec2.add(start, {0, y}))
      bounds[4] = bounds[4] + top
      util.debugRect(bounds, "blue")
      if not world.rectTileCollision(bounds) then
        world.spawnMonster("sb_ruinportal", vec2.add(start, {0, y + top}))
        stagehand.die()
        return
      end
    end
  end
end

function uninit() stagehand.die() end