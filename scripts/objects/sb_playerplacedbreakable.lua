local originalDie = die or function() end

function die(); originalDie()
  if config.getParameter("owner") then
    object.setConfigParameter("smashDropPool", "empty")
    object.setConfigParameter("breakDropPool", "empty")
    world.spawnItem(config.getParameter("objectName"), object.position())
  end
end