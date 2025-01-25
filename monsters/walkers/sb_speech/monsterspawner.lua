function init()
  local data = config.getParameter("sb_monsterspawner")
  local damageTeam = entity.damageTeam()
  world.spawnMonster(data[math.random(#data)], entity.position(),
    {
      aggressive = config.getParameter("aggressive", true),
      damageTeam = damageTeam.team,
      damageTeamType = damageTeam.type,
      level = monster.level() or world.threatLevel() or 1
    }
  )
  status.addEphemeralEffect("blackmonsterrelease")
end