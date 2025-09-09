local originalInit = init or function() end
function init() originalInit()
  local i = config.getParameter("interactData")
  local r = config.getParameter("sb_treasuredtrophies")
  for n = 1, #r do
    if world.universeFlagSet(r[n]) then
      i.filter[#i.filter+1] = "sb_treasuredtrophies_"..r[n]
    end
  end

  if not sb_storyDisablerInstalled then
    require("/scripts/sb_assetmissing.lua")
  end

  if sb_storyDisablerInstalled() then
    i.filter[#i.filter + 1] = "sb_treasuredtrophies_beamaxe2"
  end

  object.setConfigParameter("interactData",i)
  object.setConfigParameter("sb_treasuredtrophies",{}) --TODO: Don't just clear it all, check for what we've already added! We need to do this so we don't infinitely add things and cause that one issue that crashes the game when a groundfirebomb is thrown.
end