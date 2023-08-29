function init() magnet = world.spawnProjectile(config.getParameter("projectile","sb_magnet"),entity.position(),entity.id(),_,true) end
function update() if not magnet then init() elseif not world.entityExists(magnet) then init() end end
function uninit() if world.entityExists(magnet) then world.sendEntityMessage(magnet,"die") end end