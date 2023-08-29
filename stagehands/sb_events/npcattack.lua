require "/scripts/util.lua"
require "/scripts/pathutil.lua"

function init()
  self.broadcastArea = config.getParameter("broadcastArea")

  self.eventSource = config.getParameter("eventSource")
  if not self.eventSource then
    stagehand.die()
  end

  self.npcBounds = config.getParameter("npcBounds")
  self.species = config.getParameter("species")
  self.npcTypes = config.getParameter("npcTypes")
  self.spawnRange = config.getParameter("spawnRange")
  self.npcConfig = config.getParameter("npcConfig", {})

  local bounty = config.getParameter("bounty", nil)
  if bounty then
    self.npcConfig.scriptConfig = {
      bountyName = bounty
    }
  end
end

function update(dt)
  local sourcePosition = world.entityExists(self.eventSource) and world.entityPosition(self.eventSource) or false
  if not sourcePosition then
    stagehand.die()
  end

  if not world.lineTileCollision(entity.position(), sourcePosition) then
    local positions = {}
    for x = self.spawnRange[1], self.spawnRange[2] do
      local testPos = vec2.add(entity.position(), {x, 0})
      local groundPosition = findGroundPosition(testPos, self.broadcastArea[2], self.broadcastArea[4], true, nil, self.npcBounds);
      if groundPosition then
        table.insert(positions, groundPosition)
      end
    end

    shuffle(positions)
    if #positions >= #self.npcTypes then
      for i, npcType in ipairs(self.npcTypes) do
        local id = world.spawnNpc(positions[i], util.randomFromList(self.species), npcType, world.threatLevel(), nil, self.npcConfig)
        world.callScriptedEntity(id, "status.addEphemeralEffect", "beamin")
      end
      stagehand.die()
    end
  end
end

function uninit()
stagehand.die()
end