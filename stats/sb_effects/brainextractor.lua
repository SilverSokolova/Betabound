require "/scripts/util.lua"

function init()
  brain = config.getParameter("brainMap")[world.entityTypeName(entity.id())]

  if not brain then
    update = function()
      local position = entity.position()
      position[1] = position[1] + -2
      position[2] = position[2] + 0.75
      spawnNoEffectParticle("/interface/statuses/sb_brainextractorblock.png", position)
      effect.expire()
    end
    return 
  end

  if type(brain) == "number" then brain = config.getParameter("brainPool") end
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

function spawnNoEffectParticle(texture, position)
  world.spawnProjectile("invisibleprojectile", position, entity.id(), {0, 0}, false,
      {
        damageType = "nodamage",
        timeToLive = 0,
        piercing = true,
        speed = 0,
        power = 0,
        actionOnReap = {{
          action = "particle",
          specification = {
            type = "textured",
            image = texture,
            fullbright = true,
            size = 1,
            layer = "front",
            timeToLive = 0.5,
            destructionAction = "fade",
            destructionTime = 0.5,
            angularVelocity = 250,
            initialVelocity = {-2.2, 2.1}
          }
        }
      }
    }
  )
end