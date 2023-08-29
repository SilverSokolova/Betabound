require "/scripts/util.lua"
require "/scripts/pathutil.lua"

function init()
  eventSource = config.getParameter("eventSource")
  podBounds = config.getParameter("podBounds")

  monsterChance = config.getParameter("monsterSpawnChance")
  monsterSpawns = config.getParameter("monsterSpawns")

  npcSpawns = config.getParameter("npcSpawns")
end

function update(dt)
  local projectileParameters = {}
  if math.random() < monsterChance then
    local spawn = util.randomFromList(monsterSpawns)
    projectileParameters = {
      monsterType = spawn.monsterType,
      count = spawn.count
    }
  else
    local spawn = util.randomFromList(npcSpawns)
    projectileParameters = {
      npcType = spawn.npcType,
      species = util.randomFromList(spawn.species)
    }
  end

  local xOffset = math.random(-10, 10)
  local ground = vec2.add(entity.position(), {xOffset, 0})
  if world.isVisibleToPlayer(rect.translate({-1, -1, 1, 1}, ground)) then
    for y = 20, 70 do
      local air = vec2.add(ground, {0, y})
      local bounds = rect.translate(podBounds, air)
      if not world.isVisibleToPlayer(bounds) then
        world.spawnProjectile("sb_monsterspacepod", air, entity.id(), {0, -1}, false, projectileParameters)
        stagehand.die()
        return
      end
    end
  end
end

function uninit() stagehand.die() end