function init()
	local a = config.getParameter("sb_monsterspawner")
	world.spawnMonster(a[math.random(#a)],entity.position(),{aggressive=config.getParameter("aggressive",true),damageTeam=entity.damageTeam().team,level=monster.level() or world.threatLevel() or 1})
end