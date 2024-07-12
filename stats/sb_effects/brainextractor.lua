require "/scripts/util.lua"

function init()
  brain = config.getParameter("brainMap")[world.entityTypeName(entity.id())]
  if type(brain) == "number" then brain = config.getParameter("brainPool") end
  if not brain then effect.expire() return end
  effect.setParentDirectives(config.getParameter("color"))
  effect.addStatModifierGroup({{stat = "healthRegen", effectiveMultiplier = 0}})
end

--The code works how it is since it checks for a value set in init, but keep in mind the comment in extradrops-drops.lua for the extradrops tech
function uninit()
  if not status.resourcePositive("health") then
    if brain then
      world.spawnItem(root.isTreasurePool(brain) and root.createTreasure(brain,world.threatLevel())[1] or brain, entity.position())
    end
    effect.expire()
  end
end