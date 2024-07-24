local originalSpawn = spawn or function() end

function spawn() originalSpawn()
  if config.getParameter("sb_dieAfterSpawning") then object.smash(true) end
end