require("/scripts/vec2.lua")

function init()
--  mcontroller.setRotation(0)
  message.setHandler("die", function(_, _)
    projectile.die()
  end)
  message.setHandler("move", function(_, _,where)
projectile.setTimeToLive(1)
local ownerP = {0,0} --{world.entityPosition(projectile.sourceEntity())[1],world.entityPosition(projectile.sourceEntity())[2]}
mcontroller.setRotation(vec2.angle(ownerP,mcontroller.position()))
mcontroller.setPosition(where)
  end)
end