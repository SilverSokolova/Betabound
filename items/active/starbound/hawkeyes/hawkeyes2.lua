function init()
  message.setHandler("updateProjectile", function(_, _, aimPosition) mcontroller.setPosition(aimPosition) end)
  message.setHandler("kill", function() projectile.die() end)
end