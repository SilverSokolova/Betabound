local ini = init or function() end
local spaw = spawn or function() end

function init() ini()
  sb_dieAfterSpawning = config.getParameter("sb_dieAfterSpawning")
end

function spawn() spaw()
  if sb_dieAfterSpawning then object.smash(true) end
end