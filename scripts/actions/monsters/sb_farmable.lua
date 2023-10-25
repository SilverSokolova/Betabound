require "/scripts/vec2.lua"
local ini = init or function() end
function init() ini()
		message.setHandler("sb_feedFluffalo",function(_,_,feed)
      local spawnPosition = vec2.add(mcontroller.position(), vec2.mul({0,0}, {mcontroller.facingDirection(), 1}))
      local s = feed.."fluffalo"..(config.getParameter("behavior","") == "farmablebaby" and "baby" or "")
      if s == monster.type() then
        s = feed.."fluffalo"
        spawnPosition[2] = spawnPosition[2]+1
      end
      world.spawnMonster(s, spawnPosition, {level = monster.level() or 1, aggressive = false, evolveTime = config.getParameter("evolveTime",-1)}) --monster.seed monster.uniqueParameters
      monster.setDropPool(nil)
      monster.setDeathParticleBurst(nil)
      monster.setDeathSound(nil)
      status.setResource("health", 0)
		return true
	end)
end