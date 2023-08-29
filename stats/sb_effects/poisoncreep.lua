function init()
  local e, s = "foodpoison", world.entitySpecies(entity.id()) or ""
  if s == "hylotl" or s == "glitch" then e = "sb_foodheal10" end
  status.addEphemeralEffect(e,30)
  effect.expire()
end