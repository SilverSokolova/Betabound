function goodReception()
  if world.underground(object.position()) or world.type() == "unknown" then return false end
  local ll, tr = object.toAbsolutePosition{-4,1}, object.toAbsolutePosition{4,32}
  local bounds = {ll[1], ll[2], tr[1], tr[2]}
  return not world.rectTileCollision(bounds, {"Null", "Block", "Dynamic", "Slippery"})
end

function init()
  animator.setSoundPool("noise", config.getParameter("sounds",{}))
  badReception = config.getParameter("badReception")
  object.setInteractive(true)
  if not goodReception() and config.getParameter("hasAnimation",false) then
    animator.setAnimationState("beaconState", "idle")
  else
    animator.setAnimationState("beaconState", "active")
  end
end

function onInteraction(args)
  if not goodReception() then
    animator.setAnimationState("beaconState", "idle")
    animator.playSound("noise")
    if badReception[1] == "say" then object.say(badReception[2]) else return {"ShowPopup",{message=badReception[2],sound=""}} end
  else
    world.spawnProjectile(config.getParameter("projectile","regularexplosionknockback"), object.toAbsolutePosition{0,1})
    object.smash(true)
    local bosses = config.getParameter("bossType")
    bosses = type(bosses) == "string" and {bosses} or bosses
    for i = 1, #bosses do world.spawnMonster(
      bosses[i][1],
      object.toAbsolutePosition(bosses[i][2]),
        {
          level = config.getParameter("bossLevel",1) + object.level() - 1,
          aggressive = true,
          arguments = {aggressive = true}
        }
      )
    end
  end
end

function hasCapability() return false end