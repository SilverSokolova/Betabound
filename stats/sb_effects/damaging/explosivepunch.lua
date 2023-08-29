function init()
  blinkTimer = 1
  id = effect.sourceEntity() or entity.id()
end

function update(dt)
  blinkTimer = blinkTimer - dt
  if blinkTimer <= 0 then blinkTimer = 1 end
  effect.setParentDirectives(blinkTimer < 0.2 and "fade=F00;0.6" or "")
end

function uninit()
  world.spawnProjectile("fireplasmaexplosion", mcontroller.position(), 0, {0, 0}, false, {timeToLive = 0, damageTeam = world.entityDamageTeam(id), power = 90})
end