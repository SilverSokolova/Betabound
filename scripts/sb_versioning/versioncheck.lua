local originalInit = init or function() end
function init(); originalInit()
  --Unequip any non-existent techs
  local equippedTech = player.equippedTech
  local slots = {"head", "body", "legs"}
  for slot = 1, #slots do
    local tech = equippedTech(slots[slot])
    if tech then
      if not root.hasTech(tech) then
        player.unequipTech(tech)
      end
    end
  end

  local currentVersion = 35
  if player.introComplete() then
    local playerVersion = player.getProperty("betabound", {}).version or status.statusProperty("xrc_0018z", 0)
    if playerVersion < currentVersion then
      sb.logInfo(string.format("[Betabound] Okay! Updating this character from %s to %s!", playerVersion, currentVersion))
      require("/scripts/sb_versioning/versioning.lua")
      sb_doVersioning(currentVersion, playerVersion)
      sb.logInfo(string.format("[Betabound] Done! Updated this character from %s to %s!", playerVersion, currentVersion))
    end
  end
end