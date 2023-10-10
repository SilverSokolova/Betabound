function init()
	local data = config.getParameter("sb_monsterspawner")
	world.spawnMonster(data[math.random(#data)], entity.position(),
    {
      aggressive = config.getParameter("aggressive", true),
      damageTeam = entity.damageTeam().team,
      level = monster.level() or world.threatLevel() or 1
    }
  )
end