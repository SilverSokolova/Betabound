function init()
  periodicProjectile = config.getParameter("periodicProjectile")
end

function update(dt)
  for i = 1, 3 do
    projectile.processAction({
      action = "projectile",
      type = periodicProjectile,
      timeToLive = 0.1,
      angleAdjust = -math.random(90)+math.random(30)
    })
  end
end