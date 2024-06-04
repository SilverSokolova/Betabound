function init()
  message.setHandler("die", function()
    projectile.die()
  end)
  message.setHandler("move", function(_, _, pos)
    projectile.setTimeToLive(1)
    mcontroller.setPosition(pos)
  end)
end