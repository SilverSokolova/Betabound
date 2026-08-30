--Silver Sokolova
local originalInit = init or function() end

function init(); originalInit()
  local i = config.getParameter("interactData")
  local r = config.getParameter("sb_treasuredtrophies")
  local newR = {}

  for n = 1, #r do
    if world.universeFlagSet(r[n]) then
      i.filter[#i.filter + 1] = "sb_treasuredtrophies_"..r[n]
    else
      newR[#newR + 1] = r[n]
    end
  end

  object.setConfigParameter("interactData", i)
  object.setConfigParameter("sb_treasuredtrophies", newR) --We need to do this so we don't infinitely add things and cause that one issue that crashes the game when a groundfirebomb is thrown.
end