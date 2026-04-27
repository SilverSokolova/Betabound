--Can't be init because of weirdness, potentially oSB-exclusive?
function spawnMagnet()
  magnet = world.spawnProjectile(config.getParameter("projectile", "sb_magnet"), entity.position(), entity.id(), _, true)
end

function update()
  if not magnet or (magnet and not world.entityExists(magnet)) then
    spawnMagnet()
  end
end

function uninit()
  if world.entityExists(magnet) then
    world.sendEntityMessage(magnet, "die")
  end
end