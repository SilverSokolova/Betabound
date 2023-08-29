require "/scripts/rect.lua"

function init()
  requireOutOfSight = config.getParameter("requireOutOfSight", true)
  eventSource = config.getParameter("eventSource")
  if not eventSource then
    stagehand.die()
  end

  monsterType = config.getParameter("monsterType")
  bounds = rect.translate(config.getParameter("monsterBounds", {0, 0, 0, 0}), entity.position())
end

function update()
  local sourcePosition = world.entityExists(eventSource) and world.entityPosition(eventSource) or false
  if not sourcePosition then
    stagehand.die()
  end

  if not requireOutOfSight or not world.isVisibleToPlayer(bounds) then
    world.spawnMonster(monsterType, entity.position(), {aggressive=true, level = world.threatLevel(), eventSource = eventSource})
    stagehand.die()
  end
end

function uninit() stagehand.die() end