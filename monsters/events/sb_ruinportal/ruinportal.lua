require "/scripts/util.lua"
require "/scripts/pathutil.lua"

function init()
  timer = 5
  dying = false

  state = coroutine.create(invasion)
end

function update(dt)
  local s, res = coroutine.resume(state, dt)
  if not s then
    error(res)
  end
end

function invasion()
  util.wait(1.0)

  
  local spawnRange = config.getParameter("totalSpawns")
  local groundMonsters = config.getParameter("groundSpawns")
  local airMonsters = config.getParameter("airSpawns")
  
  local groundPositions = {}
  for x = -5, 5 do
    local pos = entity.position()
    local from, to = vec2.add(pos, {x, 0}), vec2.add(pos, {x, -50})
    local ground = world.collisionBlocksAlongLine(from, to)[1]
    if ground then
      table.insert(groundPositions, vec2.add(ground, {0, 1}))
    end
  end

  local spawnCount = math.random(spawnRange[1], spawnRange[2])
  for i = 1, spawnCount do
    local projectile = vec2.add(entity.position(), vec2.withAngle(math.random() * math.pi * 2, math.random() * 8))
    if #groundPositions > 0 and math.random() < 0.5 then
      local dir = vec2.norm(world.distance(util.randomFromList(groundPositions), entity.position()))
      world.spawnProjectile("spacemonsterspawner", entity.position(), entity.id(), dir, false, {
          monsterType = util.randomFromList(groundMonsters),
          monsterLevel = world.threatLevel(),
          timeToLive = 20.0,
          damageTeam = {type = "enemy"},
          aggressive = true,
          arguments = {aggressive = true}
        })
    else
      local distance = 8 + math.random() * 10
      local timeToLive = 1.0
      local spawnPosition = vec2.add(entity.position(), vec2.withAngle(math.random() * math.pi * 2, distance))
      local dir = vec2.norm(world.distance(spawnPosition, entity.position()))
      world.spawnProjectile("spacemonsterspawner", entity.position(), entity.id(), dir, false, {
          monsterType = util.randomFromList(airMonsters),
          monsterLevel = world.threatLevel(),
          onGround = false,
          damageTeam = {type = "enemy"},
	  aggressive = true,
	  arguments = {aggressive = true},
          speed = distance / timeToLive,
          timeToLive = timeToLive,
        })
    end

    util.wait(0.2 + math.random() * 0.5)
  end

  util.wait(1.0)

  animator.setAnimationState("portal", "close")

  util.wait(0.3)

  status.setResource("health", 0)

  -- wait to die
  while true do
    coroutine.yield()
  end
end