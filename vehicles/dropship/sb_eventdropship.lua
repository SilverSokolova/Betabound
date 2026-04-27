require "/vehicles/dropship/eventdropship.lua"

local originalUpdate = update or function(...) end

function update(dt); originalUpdate(dt)
  if mcontroller.isColliding() and not mcontroller.isNullColliding() then
    storage.health = storage.health - math.random(5)
    if storage.health <= 0 and not sb_spawnedNpc then
      sb_spawnedNpc = true
      local position = entity.position()
      position[1] = position[1] + (2 * config.getParameter("flyDir"))
      position[2] = position[2] + 1.75
      world.spawnNpc(position, "human", "sb_beamoutanddie", 0) --TODO: instead of human, betabound.config:protectorateSpecies?
    end
  end
end