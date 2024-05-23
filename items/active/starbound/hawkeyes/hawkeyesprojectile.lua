function init()
  oldPosition = mcontroller.position()
  message.setHandler("updateProjectile", function(_, _, aimPosition)
    if world.magnitude(aimPosition, oldPosition) > 0.1 then
      mcontroller.setPosition(aimPosition)
    end
  end)
  message.setHandler("kill", function() projectile.die() end)
end

function update()
  oldPosition = mcontroller.position()
end