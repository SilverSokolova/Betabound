function init()
  local a, b = math.floor(effect.duration()), mcontroller.position()
  status.modifyResource(config.getParameter("resource", "health"), a)
  world.spawnProjectile("invisibleprojectile",
    {b[1]-3, b[2] + config.getParameter("textOffset")}, entity.id(), {0, 0}, false,
    {damageType="nodamage",timeToLive=0,piercing=true,speed=0,power=0,
      actionOnReap = {{
        action = "particle",
        specification = {
          type = "text",
          text = string.format(config.getParameter("text"), a),
          fullbright = true,
          size = 0.5,
          layer = "front",
          timeToLive = 0.75,
          destructionAction = "shrink",
          destructionTime = 0.3
          }
        }
      }
    }
  )
  effect.expire()
  update=updat; updat=nil
end
function updat() effect.expire() end