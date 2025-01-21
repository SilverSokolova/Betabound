local originalInit = init or function() end
function init() originalInit()
    message.setHandler("sb_feedFluffalo", function(_, _, feed)
      local spawnPosition = vec2.add(mcontroller.position(), vec2.mul({0,0}, {mcontroller.facingDirection(), 1}))
      if feed.."fluffalobaby" == monster.type() then
        monsterType = feed.."fluffalo"
        spawnPosition[2] = spawnPosition[2] + 1
        world.spawnMonster(monsterType, spawnPosition, {level = monster.level() or 1, aggressive = false, evolveTime = config.getParameter("evolveTime", -1)}) --monster.seed monster.uniqueParameters
        monster.setDropPool(nil)
        monster.setDeathParticleBurst(nil)
        monster.setDeathSound(nil)
        status.setResource("health", 0)
      return true
    end
    return false
  end)
end