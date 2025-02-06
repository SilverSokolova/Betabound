function init()
  local data = config.getParameter("sb_monsterspawner")
  world.spawnMonster(data[math.random(#data)], entity.position(),
    {
      aggressive = config.getParameter("aggressive", true),
      damageTeam = entity.damageTeam().team, --Setting the damageTeamType messes things up
      level = monster.level() or world.threatLevel() or 1
    }
  )
  status.addEphemeralEffect("blackmonsterrelease")
end