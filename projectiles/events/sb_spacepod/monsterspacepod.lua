require "/scripts/vec2.lua"

function init()
  mcontroller.setRotation(0)

  monsterType = config.getParameter("monsterType")
  npcType = config.getParameter("npcType")
  species = config.getParameter("species")
  count = config.getParameter("count", 1)
end

function destroy()
  for i = 1, count do
    local entityId
    if monsterType then
      entityId = world.spawnMonster(monsterType, entity.position(), {level = world.threatLevel()})
    elseif npcType then
      entityId = world.spawnNpc(entity.position(), species, npcType, world.threatLevel())
    else
      error("No monsterType or npcType configured")
    end
    
    world.callScriptedEntity(entityId, "mcontroller.setVelocity", vec2.withAngle(math.random() * math.pi, 20))
  end
end