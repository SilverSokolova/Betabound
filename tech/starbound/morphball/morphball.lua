require "/tech/starbound/morphball/distortionsphere.lua"
local updat = update or function() end

function init()
  initCommonParameters()
  bombProjectile = config.getParameter("ballBombProjectile","sb_morphballbomb")
  bombCooldownTimer = config.getParameter("ballBombCooldown",0.5)
  bombCooldownTime = bombCooldownTimer
  bombParameters = config.getParameter("ballBombProjectileParameters",{})
  energyCostPerBomb = config.getParameter("energyCostPerBomb",15)
end

function update(args)
  updat(args)
  bombCooldownTimer = bombCooldownTimer - args.dt
  if active and args.moves["primaryFire"] and bombCooldownTimer <= 0 and status.overConsumeResource("energy", energyCostPerBomb) then
    world.spawnProjectile(bombProjectile,entity.position(),entity.id(),{0,0},false,bombParameters)
    bombCooldownTimer = bombCooldownTime
  end
end