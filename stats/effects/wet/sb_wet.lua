local ini = init or function() end
local updat = update or function() end

function init() ini()
  sb_entityId = entity.id()
end

function update(dt) updat(dt)
  if math.random(25) == 1 then
    world.spawnProjectile("sb_wet", mcontroller.position(), sb_entityId)
  end
end